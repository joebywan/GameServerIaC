provider "aws" {
  region = "us-east-1"
}

terraform {
	required_providers {
		aws = {
	    version = "~> 5.34.0"
		}
  }
}

import {
    to = aws_route53_query_log.ecs_knowhowit_com
    id = "09a7cdf0-e6cc-48bd-93c3-83957539f3dc"
}