terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region  = "ap-southeast-2"
    bucket  = "terraform-backend-knowhowit-state"
    key     = "terraform.tfstate"
    profile = ""
    encrypt = "true"

    dynamodb_table = "terraform-backend-knowhowit-state-lock"
  }
}
