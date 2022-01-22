#------------------------------------------------------------------------------
#Cloudwatch
#------------------------------------------------------------------------------
#----- Route53 Query Logging -----
#Log group for the route53 query logs to be sent to
resource "aws_cloudwatch_log_group" "route53_hosted_zone" {
  provider          = aws.us-east-1
  name              = "/aws/route53/${var.hosted_zone}"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_subscription_filter" "route53_query_log_filter" {
  provider        = aws.us-east-1
  name            = var.game_name
  log_group_name  = aws_cloudwatch_log_group.route53_hosted_zone.name
  filter_pattern  = "${var.game_name}.${var.hosted_zone}"
  destination_arn = aws_lambda_function.turn_on_server.arn
}