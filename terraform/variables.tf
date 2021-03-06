#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------
locals {
  vpc_cidr           = "${var.network_prefix}.0.0/${var.vpc_cidr_block}"
  subnet_cidrs       = cidrsubnets(local.vpc_cidr, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 12, 12, 12, 12)
  availability_zones = data.aws_availability_zones.available.names
}
#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
#Which AWS profile to use?
variable "aws_profile" {
  #Which AWS profile to use?  E.g. in the .aws/credentials file each profile is
  #preceeded by a [profile name] line. If we're using a non-default one, modify
  #it here.
  default = "alternate"
}

variable "server_region" {
  #Region the gameserver's to be deployed in
  type    = string
  default = "ap-southeast-2"
  # validation {
  #   condition = contains(
  #     [
  #       # Make list of regions
  #       "ap-southeast-2",
  #       "ap-southeast-1"
  #     ]
  #   )
  # }
}

variable "network_prefix" {
  description = "First two octets for VPC IP range"
  type        = string
  default     = "10.0"
}

variable "vpc_cidr_block" {
  description = "VPC Network CIDR block"
  type        = string
  default     = "16"
}

variable "hosted_zone" {
  description = "What's the base hosted zone name before the game specific record"
  #E.g. if you want to use minecraft.game.knowhowit.com, you need to use game.knowhowit.com here
  default = "test.knowhowit.com"
}

variable "game_name" {
  description = "What is the game called?"
  default     = "minecraft"
}

variable "lambda_location" {
  description = "Where's the lambda function file?"
  default     = "./lambda_function.py"
}

# variable "az_suffix" {
#   description = "Provides the availability zone designator"
#   default     = ["a", "b", "c"]
# }

variable "ecsports" {
  description = "ports required for the game being installed"
  type = list(
    object(
      {
        type       = string
        from_port  = number
        to_port    = number
        protocol   = string
        cidr_block = list(string)
      }
    )
  )
  default = [
    {
      type       = "ingress"
      from_port  = "25565"
      to_port    = "25565"
      protocol   = "tcp"
      cidr_block = ["0.0.0.0/0"]
    }
  ]
}

variable "sns_subscriptions" {
  description = "List if email addresses that the sns topic should send to"
  default = [
    "fuckspam@knowhowit.com"
  ]
}