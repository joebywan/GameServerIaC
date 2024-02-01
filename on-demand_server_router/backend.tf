terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region  = "ap-southeast-2"
    bucket  = "terraform-backend-knowhowit-state"
    key     = "on-demand_server_router"
    profile = ""
    encrypt = "true"

    dynamodb_table = "terraform-backend-knowhowit-state-lock"
  }
}
