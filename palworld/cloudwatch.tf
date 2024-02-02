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
