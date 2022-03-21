#------------------------------------------------------------------------------
#SNS
#------------------------------------------------------------------------------
#SNS topic to send server status updates
resource "aws_sns_topic" "server_status_updates" {
  name = "${var.game_name}-notifications"
}

#SNS subscriptions
resource "aws_sns_topic_subscription" "sns_subscription" {
  count     = length(var.sns_subscriptions)
  topic_arn = aws_sns_topic.server_status_updates.arn
  protocol  = "email"
  endpoint  = var.sns_subscriptions[count.index]
}