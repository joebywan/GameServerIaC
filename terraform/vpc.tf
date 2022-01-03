#Used to create the default vpc as an object so we can get the vpc id
resource "aws_default_vpc" "default_vpc" {
}


resource "aws_default_subnet" "default_az" {
  availability_zone = "${data.aws_region.current.name}${var.az_suffix[count.index]}"
  count = length(var.az_suffix)
}

#Create Security group to allow ECS in on required ports
resource aws_security_group "ecs_sg" {
  name = "allow_gameServer"
  description = "port(s) for gameserver"
  vpc_id = aws_default_vpc.default_vpc.id
}

resource "aws_security_group_rule" "rule" {
  count = length(var.ecsports)
  type = var.ecsports[count.index].type
  from_port = var.ecsports[count.index].from_port
  to_port = var.ecsports[count.index].to_port
  protocol = var.ecsports[count.index].protocol
  security_group_id = aws_security_group.ecs_sg.id
}