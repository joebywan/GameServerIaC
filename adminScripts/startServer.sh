#!/bin/bash
CLUSTER="palworld_cluster"
SERVICE="palworld_service"
REGION="ap-southeast-2"
DESIRED_COUNT=0
MINUTES=60
SLEEPTIME=$((0*$MINUTES))

#If the command line arg isn't given, the desired count stays as the default 0
if [ -n "$1" ]; then DESIRED_COUNT=$1; fi

sleep $(($SLEEPTIME))
# Command to be executed, modifies the desired count (aka start the container)
CURRENT_COUNT=$(aws ecs update-service --region $REGION --cluster $CLUSTER --service $SERVICE --desired-count "$DESIRED_COUNT" --query "service.desiredCount")
echo "Set current desiredCount to: $CURRENT_COUNT"

if [ "$DESIRED_COUNT" -lt 1 ]
then
    TASKID=1
    while [[ $TASKID != None ]]
    do
        TASKID=$(aws ecs list-tasks --region $REGION --cluster $CLUSTER --service-name $SERVICE --query "taskArns[0]" --output text)
    done
    echo "Server shut down"
fi