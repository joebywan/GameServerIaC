#!/bin/bash

function set_vars {
    # Retrieve the container metadata
    METADATA=$(curl -s http://169.254.170.2/v4/metadata)
    echo "Full Metadata: $METADATA"

    # Extract the cluster name and task ARN from metadata
    CLUSTER=$(echo "$METADATA" | jq -r '.Cluster')
    TASK_ARN=$(echo "$METADATA" | jq -r '.Containers[0].Labels["com.amazonaws.ecs.task-arn"]')
    echo "CLUSTER = $CLUSTER"
    echo "TASK_ARN = $TASK_ARN"

    # List all services in the cluster
    SERVICES=$(aws ecs list-services --cluster "$CLUSTER" --query "serviceArns[]" --output text)

    # Iterate through services to find which one is associated with the task ARN
    for SERVICE_ARN in $SERVICES; do
        SERVICE_TASK_ARNS=$(aws ecs list-tasks --cluster "$CLUSTER" --service-name "$SERVICE_ARN" --query "taskArns[]" --output text)
        if [[ $SERVICE_TASK_ARNS == *"$TASK_ARN"* ]]; then
            # Extract the service name from the service ARN
            SERVICE=$(echo $SERVICE_ARN | rev | cut -d'/' -f1 | rev)
            echo "SERVICE = $SERVICE"
            break
        fi
    done
}

function check_vars {
  [ -n "$CLUSTER" ] || { echo "CLUSTER env variable must be set to the name of the ECS cluster" ; exit 1; }
  [ -n "$SERVICE" ] || { echo "SERVICE env variable must be set to the name of the service in the $CLUSTER cluster" ; exit 1; }
  [ -n "$DNSADDRESS" ] || { echo "DNSADDRESS env variable must be set to the full A record in Route53 we are updating" ; exit 1; }
  [ -n "$DNSZONE" ] || { echo "DNSZONE env variable must be set to the Route53 Hosted Zone ID" ; exit 1; }
  [ -n "$STARTUPMIN" ] || { echo "STARTUPMIN env variable not set. Defaulting to a 10 minute startup wait" ; STARTUPMIN=10; }
  [ -n "$SHUTDOWNMIN" ] || { echo "SHUTDOWNMIN env variable not set. Defaulting to a 20 minute shutdown wait" ; SHUTDOWNMIN=20; }
  [ -n "$HOST" ] || { echo "HOST env variable not set. Defaulting to 127.0.0.1" ; HOST=127.0.0.1; }
  [ -n "$PORT" ] || { echo "PORT env variable not set. Defaulting to 8211" ; PORT=25575; }
  # [ -n "$ADMINPASSWORD" ] || { echo "ADMINPASSWORD env variable must be set to allow RCON communication" ; ADMINPASSWORD=$(aws ssm get-parameter --name "/palworld/rcon-password" --with-decryption --query "Parameter.Value" --output text); [ -n "$ADMINPASSWORD" ] || { echo "ADMINPASSWORD env variable must be set." ; exit 1; }}
  [ -n "$ADMINPASSWORD" ] || { echo "ADMINPASSWORD env variable must be set to allow RCON communication" ; exit 1; }
  [ -n "$SNSTOPIC" ] || { echo "SNSTOPIC env variable not set. No email notifications will be sent"; }
  echo -e "Vars set to:
CLUSTER       == $CLUSTER
SERVICE       == $SERVICE
DNSADDRESS    == $DNSADDRESS
DNSZONE       == $DNSZONE
STARTUPMIN    == $STARTUPMIN
SHUTDOWNMIN   == $SHUTDOWNMIN
HOST          == $HOST
PORT          == $PORT
ADMINPASSWORD == $ADMINPASSWORD
SNSTOPIC      == $SNSTOPIC"
}

function send_notification {
  [ "$1" = "startup" ] && MESSAGETEXT="${SERVICE} container online"
  [ "$1" = "shutdown" ] && MESSAGETEXT="Shutting down ${SERVICE}"

  ## SNS Option
  [ -n "$SNSTOPIC" ] && \
  echo "SNS topic set, sending $1 message" && \
  aws sns publish --topic-arn "$SNSTOPIC" --message "$MESSAGETEXT"
}

function zero_service {
  send_notification shutdown
  echo Setting desired task count to zero.
  aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --desired-count 0
  exit 0
}

function sigterm {
  ## upon SIGTERM set the service desired count to zero
  echo "Received SIGTERM, terminating task..."
  zero_service
}
trap sigterm SIGTERM

function set_dns_entry {
  ## get task id from the Fargate metadata
  COUNTER=0
  TASKID=None
  while [[ $TASKID == None ]]
  do
    TASKID=$(curl -s "${ECS_CONTAINER_METADATA_URI_V4}"/task | jq -r '.TaskARN' | awk -F/ '{ print $NF }')
    echo "I believe our task id is $TASKID"

    # Check if TASKID is still None
    if [[ $TASKID == None ]]; then
      if [ "$COUNTER" -gt 60 ]; then 
        echo "Failed to obtain TASKID within 60 seconds, terminating."
        exit 1
      fi
      COUNTER=$((COUNTER+1))
      sleep 1
    fi
  done

  ## get eni from from ECS
  COUNTER=0
  ENI=None
  while [[ $ENI == None ]]
  do
    ENI=$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASKID" --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text)
    echo "I believe our eni is $ENI"

    # Check if TASKID is still None
    if [[ $TASKID == None ]]; then
      if [ "$COUNTER" -gt 60 ]; then 
        echo "Failed to obtain ENI within 60 seconds, terminating."
        exit 1
      fi
      COUNTER=$((COUNTER+1))
      sleep 1
    fi
  done

  ## get public ip address from EC2
  COUNTER=0
  PUBLICIP=None
  while [[ $PUBLICIP == None ]]
  do 
    PUBLICIP=$(aws ec2 describe-network-interfaces --network-interface-ids "$ENI" --query 'NetworkInterfaces[0].Association.PublicIp' --output text)
    echo "I believe our public IP address is $PUBLICIP"

    # Check if TASKID is still None
    if [[ $TASKID == None ]]; then
      if [ "$COUNTER" -gt 60 ]; then 
        echo "Failed to obtain Public IP within 60 seconds, terminating."
        exit 1
      fi
      COUNTER=$((COUNTER+1))
      sleep 1
    fi
  done

  ## update public dns record
  echo "Updating DNS record for $DNSADDRESS to $PUBLICIP"

  # HEREDOC starts
  cat > "$SERVICE-dns.json" <<EOF
  {
      "Comment": "Fargate Public IP change for $SERVICE",
      "Changes": [
          {
              "Action": "UPSERT",
              "ResourceRecordSet": {
                  "Name": "$DNSADDRESS",
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
  # HEREDOC ends

  if aws route53 change-resource-record-sets --hosted-zone-id "$DNSZONE" --change-batch file://"$SERVICE-dns.json"; then
      echo "DNS record for $DNSADDRESS updated to $PUBLICIP"
  else
      echo "Failed to update DNS record for $DNSADDRESS"
      exit 1
  fi

}

function is_server_up {
  # Check that server is up using RCON
  COUNTER=0
  while true
  do
    # Using RCON to check server status
    CAPTUREOUTPUT=$(echo 'showplayers' | ./usr/local/bin/ARRCON --host "$HOST" --port "$PORT" --pass "$ADMINPASSWORD" 2>&1)
    echo "CAPTUREOUTPUT=$CAPTUREOUTPUT"

    # Check if the output contains player information, which indicates server is up
    if [[ $CAPTUREOUTPUT == *"name,playeruid,steamid"* ]]; then 
      echo "Server is up"
      break
    else
      echo "Server NOT up yet."
    fi

    COUNTER=$((COUNTER+1))
    # If server does not start in specified time, terminate
    if [ "$COUNTER" -gt $((60 * STARTUPMIN)) ]; then
      echo "10mins have passed without starting, terminating."
      zero_service
      break
    fi

    sleep 1
  done
}

function check_players_rcon {
  # Sending 'showplayers' command to the RCON client and capturing output
  local output
  output=$(echo 'showplayers' | ./usr/local/bin/ARRCON --host "$HOST" --port "$PORT" --pass "$ADMINPASSWORD" 2>&1)

  # Debugging: Print the entire output to stderr
  echo -e "RCON Output:\n$output" >&2

  # Check if the output contains the expected header "name,playeruid,steamid"
  if [[ "$output" == *"name,playeruid,steamid"* ]]; then
    # Counting the number of player lines based on the specified pattern
    local player_count
    player_count=$(echo "$output" | grep -c '^[^,]\+,[0-9]\+,[0-9]\+$')
    
    # Debugging: Print the calculated player count
    echo "Calculated Player Count: $player_count" >&2

    echo "$player_count"
  else
    # Debugging: Indicate an unexpected output or server down
    echo "Unexpected output or server down" >&2
    echo 0
  fi
}

function are_players_connected {
  COUNTER=0
  while [ "$COUNTER" -le "$SHUTDOWNMIN" ]
  do
    # Check the number of players connected
    PLAYERCOUNT=$(check_players_rcon)

    if [ "$PLAYERCOUNT" -lt 1 ]
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
}

# Set the variables we can acquire ourselves
set_vars
# Check that the required variables have been set
check_vars
# # Setup Route53 to point to the ECS task
set_dns_entry
# # Check whether the server is up before proceeding
is_server_up
# # Send startup notification message
send_notification startup 
# # Loop checking players are connected, then shutdown if no players are connected for $SHUTDOWNMIN
are_players_connected
echo "The script ran"