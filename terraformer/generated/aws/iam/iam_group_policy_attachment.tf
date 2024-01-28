resource "aws_iam_group_policy_attachment" "tfer--Administrators_AdministratorAccess" {
  group      = "Administrators"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "tfer--Administrators_Billing" {
  group      = "Administrators"
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}
