output "hosted_zone_ns_servers" {
    description = "Name Servers for the route53 hosted zone.  If a delegation is required, setup a delegation from the main zone to this"
    value = aws_route53_zone.public_hosted_zone.name_servers
}