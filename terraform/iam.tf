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
          Resource = "arn:aws:elasticfilesystem:${var.server_region}:${data.aws_caller_identity.current.account_id}:file-system/${aws_efs_file_system.efsFileSystem.id}"
          "Condition": {
            "StringEquals": {
              "elasticfilesystem:AccessPointArn": "arn:aws:elasticfilesystem:${var.server_region}:${data.aws_caller_identity.current.account_id}:access-point/${aws_efs_access_point.efsAccessPoint.id}"
            }
          }
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
            "arn:aws:ecs:${var.server_region}:${data.aws_caller_identity.current.account_id}:service/${var.game_name}/${var.game_name}-server",
            "arn:aws:ecs:${var.server_region}:${data.aws_caller_identity.current.account_id}:task/${var.game_name}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "ec2:DescribeNetworkInterfaces"
          ]
          Resource = [
            "*"
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
        },
        {
          Effect = "Allow"
          Action = [
            "Route53:ListHostedZones"
          ]
          Resource = "*"
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