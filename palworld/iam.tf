# If the ECS service role doesn't exist, make it.  
# resource "null_resource" "create_ecs_service_role" {
#     triggers = {
#         always_run = "${timestamp()}"
#     }

#     provisioner "local-exec" {
#         command = <<EOF
#         if ! aws iam get-role --role-name AWSServiceRoleForECS &> /dev/null; then
#             aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com
#         else
#             echo "Role already exists"
#         fi
#         EOF
#     }
# }

resource "aws_iam_role" "ecsTaskExecutionRole" {
  assume_role_policy = jsonencode({
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
    }
  ],
  "Version": "2008-10-17"
})
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  max_session_duration = "3600"
  name                 = "${local.workload_name}_ecsTaskExecutionRole"
  path                 = "/"
}

resource "aws_iam_role" "ecs_task_role" {
    name = "ecs_task_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_policy" "ecs_task_policy" {
    name   = "ecs_task_policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "ecs:DescribeTasks",
                    "ecs:ListTasks",
                ]
                Resource = [
                    "*"
                ]
            },
            {
                Effect = "Allow"
                Action = [
                    "ecs:UpdateService",
                ]
                Resource = [
                    aws_ecs_service.this.id
                ]
            },
            {
                Effect = "Allow"
                Action = [
                    "ecs:ListServices",
                ]
                Resource = [
                    "*"
                ]
            },
            {
                Effect = "Allow"
                Action = "sns:Publish"
                Resource = aws_sns_topic.this.arn
            },
            {
                Effect = "Allow"
                Action = "ec2:DescribeNetworkInterfaces"
                Resource = "*"
            },
            {
                Effect = "Allow"
                Action = "route53:ChangeResourceRecordSets"
                Resource = data.aws_route53_zone.this.arn  # Replace with your DNS Zone ID
            },
            {
                Effect = "Allow"
                Action = [
                    "elasticfilesystem:ClientMount",
                    "elasticfilesystem:ClientWrite",
                ]
                Resource = data.aws_efs_file_system.this.arn  # Replace with your EFS file system ARN
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attach" {
    role       = aws_iam_role.ecs_task_role.name
    policy_arn = aws_iam_policy.ecs_task_policy.arn
}

# Lambda function IAM resources
resource "aws_iam_policy" "lambda_discord_policy" {
    name        = "${local.workload_name}_lambda_discord_logging_and_ssm_access"
    path        = "/"
    description = "Allow Lambda to log to CloudWatch and retrieve SSM parameters"

    policy = jsonencode({
        Version: "2012-10-17",
        Statement: [
            {
                Effect: "Allow",
                Action: [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                Resource: "${aws_cloudwatch_log_group.discord_notifications.arn}:*"
            }, 
            {
                Effect: "Allow",
                Action: "ssm:GetParameter",
                Resource: [
                    aws_ssm_parameter.discord_webhook_url.arn,
                ]
            }
        ]
    })
}

resource "aws_iam_role" "lambda_discord_execution_role" {
    name = "${local.workload_name}_discord_lambda_execution_role"

    assume_role_policy = jsonencode({
        Version: "2012-10-17",
        Statement: [{
            Action: "sts:AssumeRole",
            Effect: "Allow",
            Principal: {
                Service: "lambda.amazonaws.com"
            },
        }],
    })
}

# Attach the IAM policy to the Lambda execution role
resource "aws_iam_policy_attachment" "lambda_execution_policy_attachment" {
    name       = "lambda_execution_policy_attachment"
    roles      = [aws_iam_role.lambda_discord_execution_role.name]
    policy_arn = aws_iam_policy.lambda_discord_policy.arn
}