#!/bin/bash

[ -n "$CLUSTER" ] || { echo "CLUSTER env variable must be set to the name of the ECS cluster" ; exit 1; }
[ -n "$SERVICE" ] || { echo "SERVICE env variable must be set to the name of the service in the $CLUSTER cluster" ; exit 1; }
[ -n "$SERVERNAME" ] || { echo "SERVERNAME env variable must be set to the full A record in Route53 we are updating" ; exit 1; }
[ -n "$DNSZONE" ] || { echo "DNSZONE env variable must be set to the Route53 Hosted Zone ID" ; exit 1; }
[ -n "$STARTUPMIN" ] || { echo "STARTUPMIN env variable not set, defaulting to a 10 minute startup wait" ; STARTUPMIN=10; }
[ -n "$SHUTDOWNMIN" ] || { echo "SHUTDOWNMIN env variable not set, defaulting to a 20 minute shutdown wait" ; SHUTDOWNMIN=20; }
[ -n "$QUERYPORT" ] || { echo "QUERYPORT env variable must be set to the port used to communicate with the server" ; exit 1; }

function send_notification ()
{
  [ "$1" = "startup" ] && MESSAGETEXT="${SERVICE} container online"
  [ "$1" = "shutdown" ] && MESSAGETEXT="Shutting down ${SERVICE}"

  ## SNS Option
  [ -n "$SNSTOPIC" ] && \
  echo "SNS topic set, sending $1 message" && \
  aws sns publish --topic-arn "$SNSTOPIC" --message "$MESSAGETEXT"
}

function zero_service ()
{
  send_notification shutdown
  echo Setting desired task count to zero.
  aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --desired-count 0
  exit 0
}

function sigterm ()
{
  ## upon SIGTERM set the service desired count to zero
  echo "Received SIGTERM, terminating task..."
  zero_service
}
trap sigterm SIGTERM

## get task id from the Fargate metadata
TASKID=None
while [[ $TASKID == None ]]
do
  TASKID=$(curl -s "${ECS_CONTAINER_METADATA_URI_V4}"/task | jq -r '.TaskARN' | awk -F/ '{ print $NF }')
  echo "I believe our task id is $TASKID"
done

## get eni from from ECS
ENI=""
while [[ $ENI == "" ]]
do
  ENI=$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASKID" --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text)
  echo "I believe our eni is $ENI"
done

## get public ip address from EC2
PUBLICIP=None
while [[ $PUBLICIP == None ]]
do 
  PUBLICIP=$(aws ec2 describe-network-interfaces --network-interface-ids "$ENI" --query 'NetworkInterfaces[0].Association.PublicIp' --output text)
  echo "I believe our public IP address is $PUBLICIP"
done

## update public dns record
echo "Updating DNS record for $SERVERNAME to $PUBLICIP"
## prepare json file
cat << EOF >> "$SERVICE"-dns.json
{
  "Comment": "Fargate Public IP change for $SERVICE",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$SERVERNAME",
        "Type": "A",
        "TTL": 30,
        "ResourceRecords": [
          {
            "Value": "$PUBLICIP"
          }
        ]
      }
    }
  ]
}
EOF
CAPTUREOUTPUT=$(aws route53 change-resource-record-sets --hosted-zone-id "$DNSZONE" --change-batch file://"$SERVICE"-dns.json)
echo "DNS record for $SERVERNAME updated to $PUBLICIP"

#Check that server is up
COUNTER=0
while true
do
  CAPTUREOUTPUT=$(gamedig --type valheim 127.0.0.1 "$QUERYPORT")
  if [[ $CAPTUREOUTPUT == *"ping"* ]]; then break; else sleep 1; fi
  COUNTER=$((COUNTER+1))
  if [ "$COUNTER" -gt $((60 * STARTUPMIN)) ]; then echo "10mins have passed without starting, terminating."; zero_service; fi
done
echo "Detected server, switching to shutdown watcher."

## Send startup notification message
send_notification startup 

# Server's up, now are players staying connected?
COUNTER=0
while [ "$COUNTER" -le $SHUTDOWNMIN ]
do
  # Query the server, capture the output
  CAPTUREOUTPUT=$(gamedig --type valheim 127.0.0.1 "$QUERYPORT")
  FILTER=${CAPTUREOUTPUT#*'"numplayers":'}
  PLAYERCOUNT=$(cut -d',' -f-1 <<< "$FILTER")
  if [ "$PLAYERCOUNT" -lt 1 ] || [ "$CAPTUREOUTPUT" == '{"error":"Failed all '*' attempts"}' ]
  then
    echo "$PLAYERCOUNT players connected, $COUNTER out of $SHUTDOWNMIN minutes"
    COUNTER=$((COUNTER+1))
  else
    echo "$PLAYERCOUNT players connected, counter at zero"
    COUNTER=0
  fi
  sleep 1m
done

echo "$SHUTDOWNMIN minutes elapsed without a connection, terminating."
zero_service