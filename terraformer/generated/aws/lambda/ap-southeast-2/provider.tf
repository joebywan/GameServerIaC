provider "aws" {
  region = "ap-southeast-2"
}

terraform {
	required_providers {
		aws = {
	    version = "~> 5.34.0"
		}
  }
}
