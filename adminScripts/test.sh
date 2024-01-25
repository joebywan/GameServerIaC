REMOTE_AWS_ACCOUNT=942434513370
REMOTE_ROLE=adminrole
MFA_ACCOUNT=746627761656
MFA_USERNAME=joe
read -p "Enter the MFA Code: " MFA_TOKEN_CODE

AWS_CREDENTIALS=$(aws sts assume-role --role-arn arn:aws:iam::$REMOTE_AWS_ACCOUNT:role/adminrole \
                                      --role-session-name "RoleSession1" \
                                      --serial-number arn:aws:iam::$MFA_ACCOUNT:mfa/$MFA_USERNAME \
                                      --token-code $MFA_TOKEN_CODE \
                                      | jq '.Credentials')

export AWS_ACCESS_KEY_ID=$(echo $AWS_CREDENTIALS|jq '.AccessKeyId'|tr -d '"')
export AWS_SECRET_ACCESS_KEY=$(echo $AWS_CREDENTIALS|jq '.SecretAccessKey'|tr -d '"')
export AWS_SESSION_TOKEN=$(echo $AWS_CREDENTIALS|jq '.SessionToken'|tr -d '"')
export EXPIRATION=$(echo $AWS_CREDENTIALS|jq '.Expiration'|tr -d '"')

echo AWS_SESSION_TOKEN

# AWS_ACCESS_KEY_ID=$(echo $AWS_CREDENTIALS|jq '.AccessKeyId'|tr -d '"')
# AWS_SECRET_ACCESS_KEY=$(echo $AWS_CREDENTIALS|jq '.SecretAccessKey'|tr -d '"')
# AWS_SESSION_TOKEN=$(echo $AWS_CREDENTIALS|jq '.SessionToken'|tr -d '"')
# EXPIRATION=$(echo $AWS_CREDENTIALS|jq '.Expiration'|tr -d '"')

