#------------------------------------------------------------------------------
#Lambda
#------------------------------------------------------------------------------


data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = local.lambda_location
  output_path = "lambda_function.zip"
}


#Lambda function that turns on the containers
resource "aws_lambda_function" "turn_on_server" {
  depends_on = [
    data.archive_file.lambda_function
  ]
  provider         = aws.us-east-1
  filename         = "./lambda_function.zip"
  function_name    = "${local.workload_name}-launcher"
  role             = "arn:aws:iam::746627761656:role/service-role/minecraft-launcher-role-k5ykxxb0"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256(local.lambda_location)
  runtime          = "python3.12"

  environment {
    variables = {
      game_name = local.workload_name
      region    = local.workload_region
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
  source_arn    = "${data.aws_cloudwatch_log_group.route53_hosted_zone.arn}:*"
}