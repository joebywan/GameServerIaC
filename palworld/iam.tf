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
      "Sid": ""
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