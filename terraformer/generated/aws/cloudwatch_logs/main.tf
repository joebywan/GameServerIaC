# __generated__ by Terraform from "/aws/route53/ecs.knowhowit.com|minecraft"
resource "aws_cloudwatch_log_subscription_filter" "this" {
  destination_arn = "arn:aws:lambda:us-east-1:746627761656:function:minecraft-launcher"
  distribution    = "ByLogStream"
  filter_pattern  = "[,,,url=\"minecraft.ecs.knowhowit.com\",...]"
  log_group_name  = "/aws/route53/ecs.knowhowit.com"
  name            = "minecraft"
  role_arn        = null
}

# __generated__ by Terraform from "/aws/route53/ecs.knowhowit.com"
resource "aws_cloudwatch_log_group" "this" {
  kms_key_id        = null
  log_group_class   = "STANDARD"
  name              = "/aws/route53/ecs.knowhowit.com"
  name_prefix       = null
  retention_in_days = 30
  skip_destroy      = false
  tags              = {}
  tags_all          = {}
}

