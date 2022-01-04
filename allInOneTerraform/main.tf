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
  profile = var.aws_profile
  region  = "ap-southeast-2"
}

#Added so we can do the route53 stuff in us-east-1, while doing the rest closest to us
provider "aws" {
  profile = var.aws_profile
  region  = "us-east-1"
  alias   = "us-east-1"
}

#------------------------------------------------------------------------------
#Variables
#------------------------------------------------------------------------------
#Which AWS profile to use?
variable "aws_profile" {
  #Which AWS profile to use?  E.g. in the .aws/credentials file each profile is
  #preceeded by a [profile name] line. If we're using a non-default one, modify
  #it here.
  default = "alternate"
}

variable "hosted_zone" {
  description = "What's the base hosted zone name before the game specific record"
  #E.g. if you want to use minecraft.game.knowhowit.com, you need to use game.knowhowit.com here
  default = "game.knowhowit.com"
}

variable "game_name" {
  description = "What is the game called?"
  default     = "minecraft"
}

variable "lambda_location" {
  description = "Where's the lambda function file?"
  default     = "./lambda_function.py"
}

variable "az_suffix" {
  description = "Provides the availability zone designator"
  default     = ["a", "b", "c"]
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

#------------------------------------------------------------------------------
#Data sources
#------------------------------------------------------------------------------
#Used to create the default vpc as an object so we can get the vpc id
resource "aws_default_vpc" "default_vpc" {
}


resource "aws_default_subnet" "default_az" {
  availability_zone = "${data.aws_region.current.name}${var.az_suffix[count.index]}"
  count             = length(var.az_suffix)
}

#data source for current user information.  Used to get current account id
data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

#data source to obtain route53 hosted zone information
data "aws_route53_zone" "to_be_used" {
  depends_on = [
    aws_route53_zone.public_hosted_zone
  ]
  name = var.hosted_zone
}

#------------------------------------------------------------------------------
#IAM
#------------------------------------------------------------------------------
#------------------------ IAM POLICIES ----------------------------------------
#EFS allow read/write
resource "aws_iam_policy" "efs_rw" {
  name        = "efs.rw.${var.game_name}-data"
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
  name        = "ecs.rw.${var.game_name}-service"
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
  name        = "route53.rw.${var.hosted_zone}"
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
            aws_route53_zone.public_hosted_zone.arn
          ]
        }
      ]
    }
  )
}

#SNS publish
resource "aws_iam_policy" "sns_publish" {
  name        = "sns.publish.${var.game_name}-notifications"
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
      "arn:aws:logs:*:*:log-group:/aws/route53/*",
      aws_cloudwatch_log_group.route53_hosted_zone.arn
    ]

    principals {
      type = "Service"
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
  name               = "ecs.task.${var.game_name}-server"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.efs_rw.arn,
    aws_iam_policy.ecs_rw_service.arn,
    aws_iam_policy.route53_rw.arn,
    aws_iam_policy.sns_publish.arn
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
  name               = "lambda.${var.game_name}-server"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.ecs_rw_service.arn
  ]
}

#------------------------------------------------------------------------------
#VPC
#------------------------------------------------------------------------------
#Create Security group to allow ECS in on required ports
resource "aws_security_group" "ecs_sg" {
  name        = "allow_gameServer"
  description = "port(s) for gameserver"
  vpc_id      = aws_default_vpc.default_vpc.id
}

#Create security group rules
resource "aws_security_group_rule" "rule" {
  depends_on = [
    aws_security_group.ecs_sg
  ]
  count             = length(var.ecsports)
  type              = var.ecsports[count.index].type
  from_port         = var.ecsports[count.index].from_port
  to_port           = var.ecsports[count.index].to_port
  protocol          = var.ecsports[count.index].protocol
  security_group_id = aws_security_group.ecs_sg.id
  cidr_blocks       = var.ecsports[count.index].cidr_block
}

#------------------------------------------------------------------------------
#Cloudwatch
#------------------------------------------------------------------------------
#----- Route53 Query Logging -----
#Log group for the route53 query logs to be sent to
resource "aws_cloudwatch_log_group" "route53_hosted_zone" {
  provider          = aws.us-east-1
  name              = "/aws/route53/${var.hosted_zone}"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_subscription_filter" "route53_query_log_filter" {
  provider        = aws.us-east-1
  name            = var.game_name
  log_group_name  = aws_cloudwatch_log_group.route53_hosted_zone.name
  filter_pattern  = "${var.game_name}.${var.hosted_zone}"
  destination_arn = aws_lambda_function.turn_on_server.arn
}

#------------------------------------------------------------------------------
#Route53
#------------------------------------------------------------------------------
#Create the hosted zone (makes the NS & SOA records automatically)
resource "aws_route53_zone" "public_hosted_zone" {
  name = var.hosted_zone
}

/*
Create the record that ECS will modify when the game server turns on.
1.1.1.1 will be changed, doesn't matter if Terraform resets it.
*/
resource "aws_route53_record" "game_server" {
  zone_id = aws_route53_zone.public_hosted_zone.zone_id
  name    = "${var.game_name}.${var.hosted_zone}"
  type    = "A"
  ttl     = "30"
  records = [
    "1.1.1.1"
  ]
}

/*
Enable query logging to the Cloudwatch log group to provide the data for
Lambda to trigger
*/
resource "aws_route53_query_log" "public_hosted_zone" {
  depends_on = [
    aws_cloudwatch_log_resource_policy.route53_query_logging_policy
  ]
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

#SNS subscriptions
resource "aws_sns_topic_subscription" "sns_subscription" {
  count     = length(var.sns_subscriptions)
  topic_arn = aws_sns_topic.server_status_updates.arn
  protocol  = "email"
  endpoint  = var.sns_subscriptions[count.index]
}

#------------------------------------------------------------------------------
#EFS
#------------------------------------------------------------------------------

#Where the game data will be stored
resource "aws_efs_file_system" "efsFileSystem" {
}

#Access point for EFS
resource "aws_efs_access_point" "efsAccessPoint" {
  file_system_id = aws_efs_file_system.efsFileSystem.id
  root_directory {
    path = "/${var.game_name}"
    creation_info {
      owner_gid   = "1000"
      owner_uid   = "1000"
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
  vpc_id = aws_default_vpc.default_vpc.id
  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = [aws_default_vpc.default_vpc.cidr_block]
  }
}

#------------------------------------------------------------------------------
#Lambda
#------------------------------------------------------------------------------
data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = var.lambda_location
  output_path = "./lambda_function.zip"
}

#Lambda function that turns on the containers
resource "aws_lambda_function" "turn_on_server" {
  depends_on = [
    data.archive_file.lambda_function
  ]
  provider         = aws.us-east-1
  filename         = "./lambda_function.zip"
  function_name    = "${var.game_name}-launcher"
  role             = aws_iam_role.Lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("./lambda_function.py")
  runtime          = "python3.9"

  environment {
    variables = {
      game_name = var.game_name
    }
  }
}

#Allows cloudwatch to access the lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  provider      = aws.us-east-1
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.turn_on_server.function_name
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.route53_hosted_zone.arn}:*"
}
#------------------------------------------------------------------------------
#ECS
#------------------------------------------------------------------------------
#----- ECS cluster -----
resource "aws_ecs_cluster" "ecs_cluster" {
  name               = var.game_name
  capacity_providers = ["FARGATE_SPOT"]

  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }
}

#----- ECS Service -----
resource "aws_ecs_service" "ecs_service" {
  depends_on = [
    aws_iam_policy.efs_rw
  ]
  name                   = "${var.game_name}-server"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.game_server_and_watchdog.arn
  desired_count          = 0
  enable_execute_command = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_az[0].id, aws_default_subnet.default_az[1].id, aws_default_subnet.default_az[2].id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

#----- ECS Task -----
resource "aws_ecs_task_definition" "game_server_and_watchdog" {
  family             = "${var.game_name}-server"
  task_role_arn      = aws_iam_role.ECS_role.arn
  execution_role_arn = aws_iam_role.ECS_role.arn
  requires_compatibilities = [
    "FARGATE"
  ]
  memory       = 2048
  cpu          = 1024
  network_mode = "awsvpc"

  container_definitions = jsonencode(
    [
      {
        name  = "${var.game_name}-server"
        image = "itzg/minecraft-server"

        essential = false
        portMappings = [
          {
            protocol      = "tcp"
            containerPort = 25565
            hostPort      = 25565
          }
        ]
        environment = [
          {
            name  = "EULA"
            value = "TRUE"
          }
        ]
        mountpoints = [
          {
            sourceVolume  = "data"
            containerPath = "/data"
          }
        ]
      },
      {
        name      = "${var.game_name}-ecsfargate-watchdog"
        image     = "doctorray/minecraft-ecsfargate-watchdog"
        cpu       = 10
        memory    = 256
        essential = true
        environment = [
          {
            name  = "CLUSTER"
            value = "${var.game_name}"
          },
          {
            name  = "SERVICE"
            value = "{$var.game_name}-server"
          },
          {
            name  = "DNSZONE"
            value = aws_route53_zone.public_hosted_zone.id
          },
          {
            name  = "SERVERNAME"
            value = "${var.game_name}.${var.hosted_zone}"
          },
          {
            name  = "STARTUPMIN"
            value = "10"
          },
          {
            name  = "SHUTDOWNMIN"
            value = "20"
          },
          {
            name  = "SNSTOPIC"
            value = aws_sns_topic.server_status_updates.arn
          }
        ]
      }
    ]
  )

  volume {
    name = "data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.efsFileSystem.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.efsAccessPoint.id
        iam             = "ENABLED"
      }
    }
  }
}