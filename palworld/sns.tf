resource "aws_sns_topic" "this" {
    name = "${local.workload_name}_sns_topic"
}

resource "aws_sns_topic_subscription" "this" {
    topic_arn = aws_sns_topic.this.arn
    protocol  = "email"
    endpoint  = "joseph.d.howe@gmail.com"
}
