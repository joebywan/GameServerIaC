resource "aws_iam_policy" "tfer--AWSLambdaBasicExecutionRole-04bd7863-6415-48fb-997d-919631a474d3" {
  name = "AWSLambdaBasicExecutionRole-04bd7863-6415-48fb-997d-919631a474d3"
  path = "/service-role/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Effect": "Allow",
      "Resource": "arn:aws:logs:us-east-1:746627761656:*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:us-east-1:746627761656:log-group:/aws/lambda/valheim-launcher:*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_policy" "tfer--AWSLambdaBasicExecutionRole-0db88ec4-e3aa-4e5c-b491-3bcf5dfd0701" {
  name = "AWSLambdaBasicExecutionRole-0db88ec4-e3aa-4e5c-b491-3bcf5dfd0701"
  path = "/service-role/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Effect": "Allow",
      "Resource": "arn:aws:logs:us-east-1:746627761656:*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:us-east-1:746627761656:log-group:/aws/lambda/minecraft-launcher:*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_policy" "tfer--AWSLambdaBasicExecutionRole-be7759c9-c324-403f-9200-016fc1347a61" {
  name = "AWSLambdaBasicExecutionRole-be7759c9-c324-403f-9200-016fc1347a61"
  path = "/service-role/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Effect": "Allow",
      "Resource": "arn:aws:logs:us-east-1:746627761656:*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:us-east-1:746627761656:log-group:/aws/lambda/minecraft-stopper:*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_policy" "tfer--ecs-002E-rw-002E-minecraft-service" {
  description = "This policy will allow for management of the Elastic Container Service tasks and service. This lets the Lambda function start the service, as well as allows the service to turn itself off when not in use. The ec2-DescribeNetworkInterfaces section is so that the task can determine what IP address is assigned to it to properly update the DNS record."
  name        = "ecs.rw.minecraft-service"
  path        = "/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "ecs:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ecs:ap-southeast-2:746627761656:service/minecraft/minecraft-server",
        "arn:aws:ecs:ap-southeast-2:746627761656:task/minecraft/*"
      ]
    },
    {
      "Action": [
        "ec2:DescribeNetworkInterfaces"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_policy" "tfer--ecs-002E-rw-002E-valheim-service" {
  name = "ecs.rw.valheim-service"
  path = "/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "ecs:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ecs:ap-southeast-2:746627761656:service/minecraft/valheim-server",
        "arn:aws:ecs:ap-southeast-2:746627761656:task/valheim/*"
      ]
    },
    {
      "Action": [
        "ec2:DescribeNetworkInterfaces"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  tags = {
    manual = "true"
  }

  tags_all = {
    manual = "true"
  }
}

resource "aws_iam_policy" "tfer--efs-002E-rw-002E-ark-data" {
  name = "efs.rw.ark-data"
  path = "/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Condition": {
        "StringEquals": {
          "elasticfilesystem:AccessPointArn": "arn:aws:elasticfilesystem:us-west-2:746627761656:access-point/fsap-0bcbbf71273b11b57"
        }
      },
      "Effect": "Allow",
      "Resource": "arn:aws:elasticfilesystem:us-west-2:746627761656:file-system/fs-077194a1fef069da3"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  tags = {
    server = "ark"
  }

  tags_all = {
    server = "ark"
  }
}

resource "aws_iam_policy" "tfer--efs-002E-rw-002E-minecraft-data" {
  description = "This policy will allow for read and write access to our Elastic File System Access Point"
  name        = "efs.rw.minecraft-data"
  path        = "/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Condition": {
        "StringEquals": {
          "elasticfilesystem:AccessPointArn": "arn:aws:elasticfilesystem:ap-southeast-2:746627761656:access-point/fsap-056ef92067cabb1cb"
        }
      },
      "Effect": "Allow",
      "Resource": "arn:aws:elasticfilesystem:ap-southeast-2:746627761656:file-system/fs-077194a1fef069da3"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_policy" "tfer--efs-002E-rw-002E-valheim-data" {
  name = "efs.rw.valheim-data"
  path = "/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Condition": {
        "StringEquals": {
          "elasticfilesystem:AccessPointArn": [
            "arn:aws:elasticfilesystem:ap-southeast-2:746627761656:access-point/fsap-08d5b3c7a541487d5",
            "arn:aws:elasticfilesystem:ap-southeast-2:746627761656:access-point/fsap-096e684cfe8e14cb2"
          ]
        }
      },
      "Effect": "Allow",
      "Resource": "arn:aws:elasticfilesystem:ap-southeast-2:746627761656:file-system/fs-077194a1fef069da3"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  tags = {
    manual = "true"
    server = "valheim"
  }

  tags_all = {
    manual = "true"
    server = "valheim"
  }
}

resource "aws_iam_policy" "tfer--route53-002E-rw-002E-ecs-002E-knowhowit-002E-com" {
  name = "route53.rw.ecs.knowhowit.com"
  path = "/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "route53:GetHostedZone",
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:route53:::hostedzone/Z01039561OO2DM57CFK0S",
        "arn:aws:route53:::hostedzone/Z01039561OO2DM57CFK0S"
      ]
    },
    {
      "Action": [
        "route53:ListHostedZones"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_policy" "tfer--sns-002E-publish-002E-minecraft-notifications" {
  description = "If you have decided to receive SNS notifications, we need a policy that allows publishing to the SNS topic you created."
  name        = "sns.publish.minecraft-notifications"
  path        = "/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sns:Publish",
      "Effect": "Allow",
      "Resource": "arn:aws:sns:ap-southeast-2:746627761656:minecraft-notifications"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}
