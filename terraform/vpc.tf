#------------------------------------------------------------------------------
#VPC
#------------------------------------------------------------------------------
#Create Security group to allow ECS in on required ports
resource "aws_security_group" "ecs_sg" {
  name        = "allow_ecs_gameServer"
  description = "port(s) for gameserver"
  vpc_id      = aws_default_vpc.default_vpc.id
}

#Create security group to allow NFS ports for EFS
resource "aws_security_group" "efs_sg" {
  name = "allow_nfs_ports"
  description = "Allow NFS ports through so EFS can be accessed"
  vpc_id = aws_default_vpc.default_vpc.vpc_id
}

#Create security group rules
resource "aws_security_group_rule" "rule" {
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