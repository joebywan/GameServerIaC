#------------------------------------------------------------------------------
#Variables
#------------------------------------------------------------------------------
#Which AWS profile to use?
variable "aws_profile" {
  #Which AWS profile to use?  E.g. in the .aws/credentials file each profile is
  #preceeded by a [profile name] line. If we're using a non-default one, modify
  #it here.
}

variable "server_region" {
  #Region the gameserver's to be deployed in
}

variable "hosted_zone" {
  description = "What's the base hosted zone name before the game specific record"
  #E.g. if you want to use minecraft.test.com, you need to use test.com here
}

variable "game_name" {
  description = "What is the game called?"
}

variable "lambda_location" {
  description = "Where's the lambda function file?"
}

variable "az_suffix" {
  description = "Provides the availability zone designator"
}

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
}

variable "sns_subscriptions" {
  description = "List if email addresses that the sns topic should send to"
  default = [
    "fuckspam@knowhowit.com"
  ]
}