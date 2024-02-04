resource "aws_sns_topic" "this" {
    name = "${local.workload_name}_sns_topic"
}

resource "aws_sns_topic_subscription" "this" {
    topic_arn = aws_sns_topic.this.arn
    protocol  = "email"
    endpoint  = "joseph.d.howe@gmail.com"
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
    topic_arn = aws_sns_topic.this.arn
    protocol  = "lambda"
    endpoint  = aws_lambda_function.discord_notifications.arn
}
