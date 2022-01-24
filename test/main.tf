data "aws_availability_zones" "listofaz" {
}

output "name" {
  value = data.aws_availability_zones.listofaz.names
}

resource "aws_route53_zone" "public_hosted_zone" {
  name = var.hosted_zone
}

output "zone_ns" {
  value = aws_route53_zone.public_hosted_zone.name_servers
}