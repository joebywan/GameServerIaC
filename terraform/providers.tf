#------------------------------------------------------------------------------
#Terraform/provider setup
#------------------------------------------------------------------------------

#Locks the version of the aws provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">3.70.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">2.2.0"
    }
  }
}

#Archive file provider
provider "archive" {
}

#Sets the default provider to use the region specified.
provider "aws" {
  profile = var.aws_profile
  region  = var.server_region
  # assume_role {
  #   role_arn = "arn:aws:iam::942434513370:role/adminrole"
  # }
}

#Added so we can do the route53 stuff in us-east-1, while doing the rest closest to us
provider "aws" {
  profile = var.aws_profile
  region  = "us-east-1"
  alias   = "us-east-1"
  # assume_role {
  #   role_arn = "arn:aws:iam::942434513370:role/adminrole"
  #   session_name = "test"
  # }
}