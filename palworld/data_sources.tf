data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_efs_file_system" "this" {
  tags = {
    Name = "minecraftStore"
  }
}

# Lookup the zone we're going to use
data "aws_route53_zone" "this" {
  name         = local.hosted_zone
  private_zone = false
}