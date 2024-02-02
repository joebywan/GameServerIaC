/*
Create the record that ECS will modify when the game server turns on.
1.1.1.1 will be changed, doesn't matter if Terraform resets it.
*/
resource "aws_route53_record" "game_server" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${local.workload_name}.${data.aws_route53_zone.this.name}"
  type    = "A"
  ttl     = "30"
  records = [
    "1.1.1.1"
  ]
  lifecycle {
    ignore_changes = [records]
  }
}

/*
Enable query logging to the Cloudwatch log group to provide the data for
Lambda to trigger
*/
# resource "aws_route53_query_log" "public_hosted_zone" {
#   cloudwatch_log_group_arn = data.aws_cloudwatch_log_group.route53_hosted_zone.name
#   zone_id                  = data.aws_route53_zone.this.zone_id
# }