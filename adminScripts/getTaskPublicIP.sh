#!/bin/bash

# Variables to specify (Grab these from container environment when implemented)
CLUSTER="minecraft"
SERVICE="valheim-server"

# ---- NOTE ----
# This assumes there is only 1 task required to work with, the first one.  Anymore tasks per service and they won't be looked at
# To modify we'd have to use array variables for TASKID, ENIID & PUBLICIP & For loops to iterate through them in order.
# Then creating the DNS records would be even more complicated.
# Arrays in bash: https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_10_02.html
# ---- END NOTE ----

TASKID=$(aws ecs list-tasks --cluster $CLUSTER --service-name $SERVICE --query "taskArns[0]" --output text)
ENIID=$(aws ecs describe-tasks --cluster $CLUSTER --tasks $TASKID --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value | [0]" --output text)
PUBLICIP=$(aws ec2 describe-network-interfaces --network-interface-ids $ENIID --query 'NetworkInterfaces[0].Association.PublicIp' --output text)

echo $PUBLICIP