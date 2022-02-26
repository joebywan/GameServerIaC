#!/bin/bash

# Hardcoded variables to run locally.  These will be provided via env when it moves to fargate.
CLUSTER="minecraft"
SERVICE="valheim-server"
SERVERNAME="valheim.ecs.knowhowit.com"
DNSZONE="Z01039561OO2DM57CFK0S"
STARTUPMIN=10
SHUTDOWNMIN=20
QUERYPORT=2457
SNSTOPIC="arn:aws:sns:ap-southeast-2:746627761656:minecraft-notifications"

# Check if the required environment variables have been provided & if not, exit or set defaults as required
[ -n "$CLUSTER" ] || { echo "CLUSTER env variable must be set to the name of the ECS cluster" ; exit 1; }
[ -n "$SERVICE" ] || { echo "SERVICE env variable must be set to the name of the service in the $CLUSTER cluster" ; exit 1; }
[ -n "$SERVERNAME" ] || { echo "SERVERNAME env variable must be set to the full A record in Route53 we are updating" ; exit 1; }
[ -n "$DNSZONE" ] || { echo "DNSZONE env variable must be set to the Route53 Hosted Zone ID" ; exit 1; }
[ -n "$STARTUPMIN" ] || { echo "STARTUPMIN env variable not set, defaulting to a 10 minute startup wait" ; STARTUPMIN=10; }
[ -n "$SHUTDOWNMIN" ] || { echo "SHUTDOWNMIN env variable not set, defaulting to a 20 minute shutdown wait" ; SHUTDOWNMIN=20; }
[ -n "$QUERYPORT" ] || { echo "QUERYPORT env variable must be set to the port used to communicate with the server" ; exit 1; }

#Variable to use to capture the awscli output avoiding the keyboard input required
CAPTUREOUTPUT=0

function send_notification ()
{
  [ "$1" = "startup" ] && MESSAGETEXT="${SERVICE} container online"
  [ "$1" = "shutdown" ] && MESSAGETEXT="Shutting down ${SERVICE}"

  ## SNS Option
  [ -n "$SNSTOPIC" ] && \
  echo "SNS topic set, sending $1 message" && \
  CAPTUREOUTPUT=$(aws sns publish --topic-arn "$SNSTOPIC" --message "$MESSAGETEXT")
}

function zero_service ()
{
  send_notification shutdown
  echo "Setting desired task count to zero."
  CAPTUREOUTPUT=$(aws ecs update-service --cluster $CLUSTER --service $SERVICE --desired-count 0)
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
  # TASK=$(curl -s ${ECS_CONTAINER_METADATA_URI_V4}/task | jq -r '.TaskARN' | awk -F/ '{ print $NF }') # Use for ECS version
  TASKID=$(aws ecs list-tasks --cluster $CLUSTER --service-name $SERVICE --query "taskArns[0]" --output text) # Used while testing from local machine
  echo "I believe our task id is ->$TASKID<-"
done

## get eni from from ECS
ENI=""
while [[ $ENI == "" ]]
do
  ENI=$(aws ecs describe-tasks --cluster $CLUSTER --tasks "$TASKID" --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text)
  echo "I believe our eni is ->$ENI<-"
done

## get public ip address from EC2
PUBLICIP=None
while [[ $PUBLICIP == None ]]
do
  PUBLICIP=$(aws ec2 describe-network-interfaces --network-interface-ids "$ENI" --query 'NetworkInterfaces[0].Association.PublicIp' --output text)
  echo "I believe our public IP address is ->$PUBLICIP<-"
done

## update public dns record
echo "Updating DNS record for $SERVERNAME to $PUBLICIP"
## prepare json file
rm $SERVICE-dns.json # Have to clear it, was piling up otherwise
cat << EOF >> $SERVICE-dns.json
{
	"Comment": "Fargate Public IP change for $SERVICE",
	"Changes": [{
		"Action": "UPSERT",
		"ResourceRecordSet": {
			"Name": "$SERVERNAME",
			"Type": "A",
			"TTL": 30,
			"ResourceRecords": [{
				"Value": "$PUBLICIP"
			}]
		}
	}]
}
EOF
# Do the update using the generated json policy
CAPTUREOUTPUT=$(aws route53 change-resource-record-sets --hosted-zone-id $DNSZONE --change-batch file://$SERVICE-dns.json)
echo "DNS record for $SERVERNAME updated to $PUBLICIP"


# Check that server is up
COUNTER=0
while true
do
  # Query the server
  CAPTUREOUTPUT=$(gamedig --type valheim "$PUBLICIP" "$QUERYPORT")
  # If it's got the right output, drop the loop, otherwise wait
  if [[ "$CAPTUREOUTPUT" == *"ping"* ]]; then break; else sleep 1; fi
  # Increment the shutdown counter.
  COUNTER=$((COUNTER + 1))
  # If the server isn't detected as up in $STARTUPMIN minutes, shut it down
  if [ "$COUNTER" -gt $((60 * STARTUPMIN)) ]; then echo "10mins have passed without starting, terminating."; zero_service; fi
done
echo "Detected server, switching to shutdown watcher."

## Send startup notification message
send_notification startup 

# Monitor the server for players, if none, shutdown in SHUTDOWNMIN minutes
COUNTER=0
while [ $COUNTER -le $SHUTDOWNMIN ]
do
  # Query the server and store the output
  CAPTUREOUTPUT=$(gamedig --type valheim "$PUBLICIP" $QUERYPORT)
  # Strip the output down to player count
  FILTER=${CAPTUREOUTPUT#*'"numplayers":'}
  PLAYERCOUNT=$(cut -d',' -f-1 <<< "$FILTER")

  # Test the player count, if it's 0 or if the server wasn't contactable & 
  # given an error, increment the shutdown timer
  if [ "$PLAYERCOUNT" -lt 1 ] || [ "$CAPTUREOUTPUT" == '{"error":"Failed all 1 attempts"}' ]
  then
    echo "$PLAYERCOUNT players connected, $COUNTER out of $SHUTDOWNMIN minutes"
    COUNTER=$((COUNTER +1))
  else
    echo "$PLAYERCOUNT players connected, counter at zero"
    COUNTER=0
  fi
  sleep 1m
done

# No players or not contactable for long enough, kill it
echo "$SHUTDOWNMIN minutes elapsed without a connection, terminating."
zero_service