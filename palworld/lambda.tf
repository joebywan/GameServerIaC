data "archive_file" "lambda_zip" {
    type        = "zip"
    source_file = "${path.module}/scripts/lambda_function.py"
    output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_layer_version" "requests_layer" {
    provider = aws.us-east-1
    filename   = "${path.module}/scripts/requests_layer.zip"
    layer_name = "${local.workload_name}_requests_layer"

    compatible_runtimes = ["python3.12"]
}

resource "aws_lambda_function" "discord_notifications" {
    provider = aws.us-east-1
    function_name = "${local.workload_name}_discord_notifications"
    handler       = "lambda_function.lambda_handler"
    role          = aws_iam_role.lambda_discord_execution_role.arn
    runtime       = "python3.12"  # Adjust the runtime accordingly
    timeout       = 10

    filename         = data.archive_file.lambda_zip.output_path
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
    layers = [aws_lambda_layer_version.requests_layer.arn]

    environment {
        variables = {
            # Define any environment variables your Lambda needs, if any
        }
    }
}

