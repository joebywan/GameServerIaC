#------------------------------------------------------------------------------
#Terraform/provider setup
#------------------------------------------------------------------------------

#Locks the version of the aws provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.70.0"
    }
  }
}

#Sets the default provider to use the region specified.
provider aws {
    region = "ap-southeast-2"
}

#Added so we can do the route53 stuff in us-east-1, while doing the rest closest to us
provider aws {
    region = "us-east-1"
    alias = "us-east-1"
}

#------------------------------------------------------------------------------
#Variables
#------------------------------------------------------------------------------


variable "hosted_zone" {
  description = "What's the base hosted zone name before the game specific record"
  #E.g. if you want to use minecraft.game.knowhowit.com, you need to use game.knowhowit.com here
  default = "game.knowhowit.com"  
}

variable "game_name" {
  description = "What is the game called?"
  default = "minecraft"
}

variable "lambda_location" {
  description = "Where's the lambda function file?"
  default = "./lambda_function.py"
}

#------------------------------------------------------------------------------
#Data sources
#------------------------------------------------------------------------------
#Used to create the default vpc as an object so we can get the vpc id
resource "aws_default_vpc" "default_vpc" {
}

#data source for current user information.  Used to get current account id
data "aws_caller_identity" "current" { 
}

#data source to obtain route53 hosted zone information
data "aws_route53_zone" "to_be_used" {
  name = "${var.hosted_zone}"
}

#------------------------------------------------------------------------------
#IAM
#------------------------------------------------------------------------------
#------------------------ IAM POLICIES ----------------------------------------
#EFS allow read/write
resource "aws_iam_policy" "efs_rw" {
  name = "efs.rw.${var.game_name}-data"
  description = "Policy to allow read & write for EFS"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "elasticfilesystem:ClientMount",
            "elasticfilesystem:ClientWrite",
            "elasticfilesystem:DescribeFileSystems"
          ]
          Resource = "arn:aws:elasticfilesystem:us-west-2:${data.aws_caller_identity.current.account_id}:file-system/${aws_efs_file_system.efsFileSystem.id}"
        }
      ]
    }
  )
}

#ECS admin policy
resource "aws_iam_policy" "ecs_rw_service" {
  name = "ecs.rw.${var.game_name}-service"
  description = "Policy to allow administration of ECS"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecs:*"
          ]
          Resource = [
            "arn:aws:ecs:us-west-2:${data.aws_caller_identity.current.account_id}:service/${var.game_name}/${var.game_name}-server",
            "arn:aws:ecs:us-west-2:${data.aws_caller_identity.current.account_id}:task/${var.game_name}/*"
          ]
        }
      ]
    }
  )
}

#Route 53 read/write
resource "aws_iam_policy" "route53_rw" {
  name = "ecs.rw.${var.game_name}-service"
  description = "Enables read/write of specified Route53 Hosted Zone"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "route53:GetHostedZone",
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets"
          ]
          Resource = [
            "${data.aws_route53_zone.to_be_used.arn}"
          ]
        }
      ]
    }
  )
}

#SNS publish
resource "aws_iam_policy" "sns_publish" {
  name = "sns.publish.${var.game_name}-notifications"
  description = "SNS allow publish"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sns:Publish"
          ]
          Resource = [
            aws_sns_topic.server_status_updates.arn
          ]
        }
      ]
    }
  )
}

#Making the log policy document to put in the log policy
data "aws_iam_policy_document" "route53_query_logging_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.route53_hosted_zone
    ]

    principals {
      type        = "Service"
      identifiers = [
        "route53.amazonaws.com"
      ]
    }
  }
}

#Creating the log policy using the previously made document
resource "aws_cloudwatch_log_resource_policy" "route53_query_logging_policy" {
  provider = aws.us-east-1

  policy_document = data.aws_iam_policy_document.route53_query_logging_policy.json
  policy_name     = "route53_query_logging_policy"
}

#------------------------ IAM ROLES -------------------------------------------
#----- ECS role -----
#Have to make the assume role policy first
data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

#Then we make the role itself
resource "aws_iam_role" "ECS_role" {
  name = "ecs.task.${var.game_name}-server"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  managed_policy_arns = [
      aws_iam_policy.efs_rw.arn,
      aws_iam_policy.ecs_rw_service,
      aws_iam_policy.route53_rw,
      aws_iam_policy.sns_publish
    ]
}

#----- Lambda Role -----
#Have to make the assume role policy first
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

#Then we make the role itself
resource "aws_iam_role" "Lambda_role" {
  name = "lambda.${var.game_name}-server"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [
      aws_iam_policy.ecs_rw_service
    ]
}

#------------------------------------------------------------------------------
#Cloudwatch
#------------------------------------------------------------------------------
#----- Route53 Query Logging -----
#Log group for the route53 query logs to be sent to
resource "aws_cloudwatch_log_group" "route53_hosted_zone" {
  provider = aws.us-east-1

  name              = "/aws/route53/${var.hosted_zone}"
  retention_in_days = 3
}
#------------------------------------------------------------------------------
#Route53
#------------------------------------------------------------------------------
#Create the hosted zone (makes the NS & SOA records automatically)
resource "aws_route53_zone" "public_hosted_zone" {
  name = "${var.hosted_zone}"
}

/*
Create the record that ECS will modify when the game server turns on.
1.1.1.1 will be changed, doesn't matter if Terraform resets it.
*/
resource "aws_route53_record" "game_server" {
  zone_id = aws_route53_zone.public_hosted_zone.zone_id
  name = "${var.game_name}.${var.hosted_zone}"
  type = "A"
  ttl = "30"
  records = [
    "1.1.1.1"
  ]
}

/*
Enable query logging to the Cloudwatch log group to provide the data for
Lambda to trigger
*/
resource "aws_route53_query_log" "public_hosted_zone" {
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53_hosted_zone.arn
  zone_id                  = aws_route53_zone.public_hosted_zone.zone_id
}

#------------------------------------------------------------------------------
#SNS
#------------------------------------------------------------------------------
#SNS topic to send server status updates
resource "aws_sns_topic" "server_status_updates" {
  name = "${var.game_name}-notifications"
}

#------------------------------------------------------------------------------
#EFS
#------------------------------------------------------------------------------

#Where the game data will be stored
resource "aws_efs_file_system" "efsFileSystem" {
}

#Access point for EFS
resource "aws_efs_access_point" "efsAccessPoint" {
  file_system_id = aws_efs_file_system.efsFileSystem
  root_directory {
    path = "/${var.game_name}"
    creation_info {
        owner_gid = "1000"
        owner_uid = "1000"
        permissions = "0755"
    }
  }
  posix_user {
    gid = "1000"
    uid = "1000"
  }
}

#Allow EFS on default security group
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_default_vpc.default_vpc
  ingress {
      protocol = "tcp"
      self = true
      from_port = 2049
      to_port = 2049
      cidr_blocks = [aws_default_vpc.default_vpc.cidr_block]
  }
}

#------------------------------------------------------------------------------
#Lambda
#------------------------------------------------------------------------------
#Lambda function that turns on the containers
resource "aws_lambda_function" "turn_on_server" {
  filename = "${var.lambda_location}"
  function_name = "${var.game_name}-launcher"
  role = aws_iam_role.Lambda_role
  source_code_hash = filebase64sha256("${var.lambda_location}")
  runtime = "python3.8"

  environment {
    variables = {
      game_name = var.game_name
    }
  }
}

# resource "aws_ecs_task_definition" "game_server" {
#   family = "${game-name}-server"
#   container_definitions = jsonencode([
#     {
#       name      = "${var.game_name}-server"
#       image     = "itzg/minecraft-server"
#       cpu       = 1
#       memory    = 2048
#       essential = false
#       portMappings = [
#         {
#           protocol = "tcp"
#           containerPort = 25565
#           hostPort      = 25565
#         }
#       ]
#     },
#     {
#       name      = "second"
#       image     = "service-second"
#       cpu       = 10
#       memory    = 256
#       essential = true
#       portMappings = [
#         {
#           containerPort = 443
#           hostPort      = 443
#         }
#       ]
#     }
#   ])

#   volume {
#     name      = "service-storage"
#     host_path = "/ecs/service-storage"
#   }

#   placement_constraints {
#     type       = "memberOf"
#     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
#   }
# }

