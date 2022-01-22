#------------------------------------------------------------------------------
#Terraform/provider setup
#------------------------------------------------------------------------------

#Locks the version of the aws provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }
}

#Archive file provider
provider "archive" {
}

#Sets the default provider to use the region specified.
provider "aws" {
  region  = "ap-southeast-2"
}

#Added so we can do the route53 stuff in us-east-1, while doing the rest closest to us
provider "aws" {
  profile = var.aws_profile
  region  = "us-east-1"
  alias   = "us-east-1"
}