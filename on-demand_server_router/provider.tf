terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
  }
}

provider "aws" {
  region = local.workload_region
  default_tags {
    tags = local.default_tags
  }
}
