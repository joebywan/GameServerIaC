# Log group for the ECS logs to be sent to
resource "aws_cloudwatch_log_group" "ecs_log_group_server" {
  name              = "/ecs/${local.workload_name}-server"
  retention_in_days = 3
}

moved {
  from = aws_cloudwatch_log_group.ecs_log_group
  to   = aws_cloudwatch_log_group.ecs_log_group_server
}

# Log group for the ECS logs to be sent to
resource "aws_cloudwatch_log_group" "ecs_log_group_watchdog" {
  name              = "/ecs/${local.workload_name}-watchdog"
  retention_in_days = 3
}

# Log group for the route53 query logs to be sent to
data "aws_cloudwatch_log_group" "route53_hosted_zone" {
  provider = aws.us-east-1
  name     = "/aws/route53/${local.hosted_zone}"
}

# Subscription Filter that triggers Lambda when new queries take place
# resource "aws_cloudwatch_log_subscription_filter" "route53_query_log_filter" {
#   provider        = aws.us-east-1
#   name            = local.workload_name
#   log_group_name  = data.aws_cloudwatch_log_group.route53_hosted_zone.name
#   # filter_pattern  = "${local.workload_name}.${data.aws_route53_zone.this.name}"
#   filter_pattern = "[,,,url=\"${local.workload_name}.${data.aws_route53_zone.this.name}\",...]"
#   destination_arn = aws_lambda_function.turn_on_server.arn
# }