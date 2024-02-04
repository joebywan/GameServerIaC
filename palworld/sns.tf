resource "aws_sns_topic" "this" {
    provider = aws.us-east-1
    name = "${local.workload_name}_sns_topic"
}

resource "aws_sns_topic_subscription" "this" {
    provider = aws.us-east-1
    topic_arn = aws_sns_topic.this.arn
    protocol  = "email"
    endpoint  = "joseph.d.howe@gmail.com"
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
    provider = aws.us-east-1
    topic_arn = aws_sns_topic.this.arn
    protocol  = "lambda"
    endpoint  = aws_lambda_function.discord_notifications.arn
}
