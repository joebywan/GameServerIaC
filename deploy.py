import boto3
# import os

# defaultvpc = str(os.system('aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[*].VpcId" --output text'))
from subprocess import PIPE, run

#function to take os command output and return it.  To be used in other functions or variables.  Eliminates the error code return fouling up the return.
def out(command):
    result = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True, shell=True)
    return result.stdout

#contains the default VPC id
defaultvpc = out('aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[*].VpcId" --output text')

