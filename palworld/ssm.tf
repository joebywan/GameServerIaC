resource "aws_ssm_parameter" "discord_webhook_url" {
    name        = "${local.workload_name}_discord_webhook_url"
    description = "Discord webhook URL for ${local.workload_name}"
    type        = "SecureString"
    # type = "String"
    value       = "your_discord_webhook_url_here"  # Replace with your actual webhook URL
    key_id      = "alias/aws/ssm"  # Optional: specify a custom KMS key ID if not using the default

    lifecycle {
        ignore_changes = [value]
    }
}