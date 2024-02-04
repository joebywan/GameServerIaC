import json
import requests
import logging

# Initialize logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Load the configuration from blah.private
with open('blah.private', 'r') as config_file:
    config = json.load(config_file)

webhook_url = config["test_webhook"]
print(f"webhook_url:{webhook_url}")

# Sample SNS message (simulated as a dictionary for demonstration)
sns_message = {
    'Records': [{
        'EventSource': 'aws:sns',
        'Sns': {
            'Message': 'TEST MESSAGE FROM JOE',
            'Subject': 'test-subject',
        }
    }]
}

def format_sns_message_to_embed(sns_message):
    """Format an SNS message to Discord embed fields."""
    sns_record = sns_message['Records'][0]['Sns']
    return [
        {'name': 'Server_Status', 'value': ":white_check_mark: Online", 'inline': True},
        {'name': 'URL', 'value': "palworld.ecs.knowhowit.com:8211", 'inline': True}
    ]

def handler():
    embed_fields = format_sns_message_to_embed(sns_message)
    discord_data = {
        'username': 'AWS Notification',
        'avatar_url': 'https://img.game8.co/3820250/bfd9f77c798fbb2cd6a3dee41cb54924.png/show',
        'embeds': [{
            'title': 'AWS SNS Notification',
            'color': 16711680,
            'fields': embed_fields
        }]
    }

    headers = {'Content-Type': 'application/json'}
    response = requests.post(webhook_url, data=json.dumps(discord_data), headers=headers)

    logging.info(f'Discord response: {response.status_code}')
    logging.info(response.content.decode('utf-8'))

if __name__ == "__main__":
    handler()
