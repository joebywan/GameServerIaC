provider "aws" {
  region = "us-east-1"
}

# provider "aws" {
#     alias = "us-east-1"
#     region = "us-east-1"
# }

terraform {
	required_providers {
		aws = {
	    version = "~> 5.34.0"
		}
  }
}
