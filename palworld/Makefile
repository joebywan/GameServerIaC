# Makefile to manage Terraform with AWS credentials

# Function to check and use AWS credentials
define check_aws_credentials
    ifndef AWS_ACCESS_KEY_ID
        $(error AWS_ACCESS_KEY_ID is not set)
    endif
    ifndef AWS_SECRET_ACCESS_KEY
        $(error AWS_SECRET_ACCESS_KEY is not set)
    endif
    AWS_CREDENTIALS := AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY}
    ifdef AWS_SESSION_TOKEN
        AWS_CREDENTIALS := $${AWS_CREDENTIALS} AWS_SESSION_TOKEN=$${AWS_SESSION_TOKEN}
    endif
    ifdef AWS_PROFILE
        AWS_CREDENTIALS := $${AWS_CREDENTIALS} AWS_PROFILE=$${AWS_PROFILE}
    endif
endef

# Terraform commands
init:
    @$(call check_aws_credentials) terraform init

plan:
    @$(call check_aws_credentials) terraform plan

apply:
    @$(call check_aws_credentials) terraform apply

destroy:
    @$(call check_aws_credentials) terraform destroy

# Add other Terraform commands as needed

.PHONY: init plan apply destroy
