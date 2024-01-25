#------------------------------------------------------------------------------
#VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block = local.vpc_cidr
  tags = {
    Name = "${var.game_name}_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.game_name}_igw"
  }
}

resource "aws_route" "igwRouteEntry" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "subnet" {
  count             = length(local.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]
  tags = {
    Name = "${var.game_name}_subnet"
  }
}

#Create Security group to allow ECS in on required ports
resource "aws_security_group" "ecs_sg" {
  name        = "allow_ecs_gameServer"
  description = "port(s) for gameserver"
  vpc_id      = aws_vpc.vpc.id
}

#Create security group to allow NFS ports for EFS
resource "aws_security_group" "efs_sg" {
  name        = "allow_nfs_ports"
  description = "Allow NFS ports through so EFS can be accessed"
  vpc_id      = aws_vpc.vpc.id
}

#Create security group rules
resource "aws_security_group_rule" "ecs_sg_rule" {
  depends_on = [
    aws_security_group.ecs_sg
  ]
  count             = length(var.ecsports)
  type              = var.ecsports[count.index].type
  from_port         = var.ecsports[count.index].from_port
  to_port           = var.ecsports[count.index].to_port
  protocol          = var.ecsports[count.index].protocol
  security_group_id = aws_security_group.ecs_sg.id
  cidr_blocks       = var.ecsports[count.index].cidr_block
}

resource "aws_security_group_rule" "efs_sg_rule" {
  depends_on = [
    aws_security_group.efs_sg
  ]
  count             = length(var.efsports)
  type              = var.efsports[count.index].type
  from_port         = var.efsports[count.index].from_port
  to_port           = var.efsports[count.index].to_port
  protocol          = var.efsports[count.index].protocol
  security_group_id = aws_security_group.efs_sg.id
  cidr_blocks       = var.efsports[count.index].cidr_block
}