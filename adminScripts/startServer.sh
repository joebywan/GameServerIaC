#!/bin/bash
CLUSTER="minecraft"
SERVICE="ark-server"
#TASK_DEFINITION="ark-server"
#REVISION="1"
DESIRED_COUNT=0

#If the command line arg isn't given, the desired count stays as the default 0
if [ ! -z "$1" ]; then DESIRED_COUNT=$1; fi

#Command to be executed, modifies the desired count (aka start the container)
aws ecs update-service --cluster $CLUSTER --service $SERVICE --desired-count $DESIRED_COUNT