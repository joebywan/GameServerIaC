import boto3
# import os

# defaultvpc = str(os.system('aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[*].VpcId" --output text'))
from subprocess import PIPE, run

def out(command):
    result = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True, shell=True)
    return result.stdout

defaultvpc = out('aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[*].VpcId" --output text')
print(type(defaultvpc))
print("defaultVPC id is " + defaultvpc)
print("|" + defaultvpc + "|")

# ec2 = boto3.client('ec2')
# filters = [{'Name':'isDefault','Values'='true'}]
# default_vpc_id = ec2.describe_vpcs()
# print(default_vpc_id)

#default_vpc_id=$(aws ec2 describe-vpcs \
#    --filters Name=isDefault,Values=true \
#    --query 'Vpcs[*].VpcId' \
#    --output text)