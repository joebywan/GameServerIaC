import sys
sys.path.insert(0, 'package/')
import json
import requests
import os
import logging
import boto3
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Function to split the string by spaces, concatenating the first two elements into 1, and returning the 3rd as a 2nd.
def split_string(s):
    # Split the string by spaces
    parts = s.split(' ')

    # Build the action by joining the first two elements of parts
    action = ' '.join(parts[:2])
    logger.info(f"action: {action}")

    # Build the service by taking the last element of parts and splitting it by _, we only need the first one.
    service = parts[2].split('_')[0]
    logger.info(f"service: {service}")

    # return parts 1 and 2 in a list
    return [action, service]

def build_discord_message(action, service_name):

    status_message = {
        "Starting up": (":white_check_mark: Online", 1503510),
        "Shutting down": (":octagonal_sign: Offline", 15158332)
    }.get(action, (":grey_question: Unknown Status", 8359053))

    discord_message_payload = {
        "embeds": [
            {
                "title": f"Server Notification for {service_name}",
                "color": status_message[1],
                "fields": [
                    {
                        "name": "Server Status",
                        "value": status_message[0],
                        "inline": True
                    },
                    {
                        "name": "URL",
                        "value": "palworld.ecs.knowhowit.com:8211",
                        "inline": True
                    }
                ]
            }
        ],
        "username": "Server Notifications",
    }

    return discord_message_payload

def send_discord_message(discord_message, webhook_url):
    headers = {'Content-Type': 'application/json'}
    response = requests.post(webhook_url, data=json.dumps(discord_message), headers=headers)
    logging.info(f'Discord response: {response.status_code}')
    logging.info(response.content.decode('utf-8'))
    return response.status_code

def get_discord_webhook_url(service_name):
    """
    Retrieves the Discord webhook URL from an SSM secure parameter.

    :param service_name: Name of the service to construct the parameter name.
    :return: The Discord webhook URL.
    """
    # Initialise boto3's ssm client
    ssm = boto3.client('ssm')

    # Construct the parameter name
    parameter_name = f"{service_name}_discord_webhook_url"
    
    # Retrieve the parameter value
    response = ssm.get_parameter(
        Name=parameter_name,
        WithDecryption=True  # Set to True to decrypt the parameter
    )
    
    # Extract the parameter value
    parameter_value = response['Parameter']['Value']
    logging.info(f"Retrieved webhook URL")
    return parameter_value

def lambda_handler(event, context):
    # Get the SNS message
    message = event['Records'][0]['Sns']['Message']
    logger.info(message)

    # Split it up so we can use it to discern what's going on
    action, service_name = split_string(message)

    # Build the discord payload we'll send as a notification
    discord_message = build_discord_message(action, service_name)

    webhook_url = get_discord_webhook_url(service_name)
    send_discord_message(discord_message, webhook_url)

    return {
        'statusCode': 200,
        'body': json.dumps('Log processed successfully')
    }




    


