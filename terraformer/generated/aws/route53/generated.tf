# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "09a7cdf0-e6cc-48bd-93c3-83957539f3dc"
resource "aws_route53_query_log" "ecs_knowhowit_com" {
  cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:746627761656:log-group:/aws/route53/ecs.knowhowit.com:*"
  zone_id                  = "Z01039561OO2DM57CFK0S"
}
