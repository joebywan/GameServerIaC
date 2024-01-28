resource "aws_iam_instance_profile" "tfer--SSM_Access" {
  name = "SSM_Access"
  path = "/"
  role = "SSM_Access"
}

resource "aws_iam_instance_profile" "tfer--ec2-ssm-instance-profile" {
  name = "ec2-ssm-instance-profile"
  path = "/"
  role = "ssm-ec2"
}
