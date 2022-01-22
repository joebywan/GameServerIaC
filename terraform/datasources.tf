#------------------------------------------------------------------------------
#Data sources
#------------------------------------------------------------------------------
#Used to create the default vpc as an object so we can get the vpc id
resource "aws_default_vpc" "default_vpc" {
}


resource "aws_default_subnet" "default_az" {
  availability_zone = "${data.aws_region.current.name}${var.az_suffix[count.index]}"
  count             = length(var.az_suffix)
}

#data source for current user information.  Used to get current account id
data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

#data source to obtain route53 hosted zone information
data "aws_route53_zone" "to_be_used" {
  depends_on = [
    aws_route53_zone.public_hosted_zone
  ]
  name = var.hosted_zone
}

data "aws_subnet_ids" "defaultVPCSubnetIds" {
  vpc_id = aws_default_vpc.default_vpc.id
}