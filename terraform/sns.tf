#------------------------------------------------------------------------------
#SNS
#------------------------------------------------------------------------------
#SNS topic to send server status updates
resource "aws_sns_topic" "server_status_updates" {
  name = "${var.game_name}-notifications"
}