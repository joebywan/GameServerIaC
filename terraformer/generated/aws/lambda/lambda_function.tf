resource "aws_lambda_function" "tfer--minecraft-launcher" {
  architectures = ["x86_64"]

  ephemeral_storage {
    size = "512"
  }

  function_name = "minecraft-launcher"
  handler       = "lambda_function.lambda_handler"

  logging_config {
    log_format = "Text"
    log_group  = "/aws/lambda/minecraft-launcher"
  }

  memory_size                    = "128"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "arn:aws:iam::746627761656:role/service-role/minecraft-launcher-role-k5ykxxb0"
  runtime                        = "python3.9"
  skip_destroy                   = "false"
  source_code_hash               = "BjNTS26AHa17sFv1b//bQOwQ7zAhn83yXWcsATGHU4g="
  timeout                        = "3"

  tracing_config {
    mode = "PassThrough"
  }
}
