data "archive_file" "lambda_zip" {
    type        = "zip"
    source_file = "${path.module}/scripts/start_service.py"
    output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "ecs_lambda" {
    function_name = "${local.workload_name}-lambda_function"
    filename      = data.archive_file.lambda_zip.output_path

    handler = "start_service.lambda_handler"
    runtime = "python3.12"
    role    = aws_iam_role.lambda_role.arn
    timeout = 5

    source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

    environment {
        variables = {
            SERVICE_MAPPING = jsonencode(local.service_mapping)
        }
    }

}
