resource "aws_iam_user_policy" "tfer--joe_assumerole" {
  name = "assumerole"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Resource": "arn:aws:iam::942434513370:role/adminrole",
      "Sid": "VisualEditor0"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  user = "joe"
}
