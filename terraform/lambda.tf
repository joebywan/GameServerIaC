#------------------------------------------------------------------------------
#Lambda
#------------------------------------------------------------------------------
data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = var.lambda_location
  output_path = "./lambda_function.zip"
}

#Lambda function that turns on the containers
resource "aws_lambda_function" "turn_on_server" {
  depends_on = [
    data.archive_file.lambda_function
  ]
  provider         = aws.us-east-1
  filename         = "./lambda_function.zip"
  function_name    = "${var.game_name}-launcher"
  role             = aws_iam_role.Lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("./lambda_function.py")
  runtime          = "python3.9"

  environment {
    variables = {
      game_name = var.game_name
      region    = var.server_region
    }
  }
}

#Allows cloudwatch to access the lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  provider      = aws.us-east-1
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.turn_on_server.function_name
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.route53_hosted_zone.arn}:*"
}