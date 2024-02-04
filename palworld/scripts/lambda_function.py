import json
import requests
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
    logging.info(f"action: {action}")

    # Build the service by taking the last element of parts and splitting it by _, we only need the first one.
    service = parts[2].split('_')[0]
    logging.info(f"service: {service}")

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
        'avatar_url': 'https://img.game8.co/3820250/bfd9f77c798fbb2cd6a3dee41cb54924.png/show',
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
    ssm = boto3.client('ssm', region_name='us-east-1')

    # Construct the parameter name
    parameter_name = f"{service_name}_discord_webhook_url".lower()
    print(f"parameter_name: {parameter_name}")
    
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
    logging.info(message)

    # Split it up so we can use it to discern what's going on
    action, service_name = split_string(message)

    # Build the discord payload we'll send as a notification
    discord_message = build_discord_message(action, service_name)

    # Retrieve the webhook url from ssm
    webhook_url = get_discord_webhook_url(service_name)

    # Send the message to discord
    send_discord_message(discord_message, webhook_url)

    return {
        'statusCode': 200,
        'body': json.dumps('Log processed successfully')
    }

# Only required for testing locally

# if __name__ == "__main__":
#     event = {
#         'Records': [
#             {
#                 'EventSource': 'aws:sns',
#                 'EventVersion': '1.0',
#                 'EventSubscriptionArn': 'arn:aws:sns:us-east-1:746627761656:test:a5fd1005-d84a-4756-8982-59b38dfb1bfa',
#                     'Sns': {
#                         'Type': 'Notification',
#                         'MessageId': '32295e65-7914-57ee-bdae-005dc2096548',
#                         'TopicArn': 'arn:aws:sns:us-east-1:746627761656:test',
#                         'Subject': 'test-subject',
#                         'Message': 'Shutting down Palworld_service',
#                         'Timestamp': '2024-02-03T22:06:21.289Z', 'SignatureVersion': '1', 'Signature': 're3d5tHqLv4eFxian8KwjdkXJs2XVT4EOkP8d5ZYnGYh5SxeDLLO4Zg9TH0WM/UK4zsI0OFq1f1k93uA5u9FpSk1vrH79doeU3Cg3l+Vc9069H+nFa9sREZN+3btWOdd1Hg89MD5mnsVG+izRopUKOc6YlzCrDqGqr5+bOB5SnUaghehOToPe30fCND8xaqScSg40NQbfSKKxFwzYNaA4YFHMMLiFS2KjfR0SKUjtIqSL+BZS/ovo54YL1WeULT7xJZdVZBs6U5Zva8WP9ICWmKzjrT3pynP85SqhczTxsXYAq0g30OdaSC85OpuEWilul2wVcZ8HzJzn6Y/xDk9Dw==', 'SigningCertUrl': 'https://sns.us-east-1.amazonaws.com/SimpleNotificationService-60eadc530605d63b8e62a523676ef735.pem', 'UnsubscribeUrl': 'https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:746627761656:test:a5fd1005-d84a-4756-8982-59b38dfb1bfa', 'MessageAttributes': {}}}]}

#     lambda_handler(event, None)
