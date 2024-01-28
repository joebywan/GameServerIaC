resource "aws_iam_user_group_membership" "tfer--joe-002F-Administrators" {
  groups = ["Administrators"]
  user   = "joe"
}
