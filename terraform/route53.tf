#------------------------------------------------------------------------------
#Route53
#------------------------------------------------------------------------------
#Create the hosted zone (makes the NS & SOA records automatically)
resource "aws_route53_zone" "public_hosted_zone" {
  name = var.hosted_zone
}

/*
Create the record that ECS will modify when the game server turns on.
1.1.1.1 will be changed, doesn't matter if Terraform resets it.
*/
resource "aws_route53_record" "game_server" {
  zone_id = aws_route53_zone.public_hosted_zone.zone_id
  name    = "${var.game_name}.${var.hosted_zone}"
  type    = "A"
  ttl     = "30"
  records = [
    "1.1.1.1"
  ]
}

/*
Enable query logging to the Cloudwatch log group to provide the data for
Lambda to trigger
*/
resource "aws_route53_query_log" "public_hosted_zone" {
  depends_on = [
    aws_cloudwatch_log_resource_policy.route53_query_logging_policy
  ]
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53_hosted_zone.arn
  zone_id                  = aws_route53_zone.public_hosted_zone.zone_id
}