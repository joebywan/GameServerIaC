#Create Security group to allow ECS in on required ports
resource "aws_security_group" "ecs_sg" {
  name        = "allow_ecs_gameServer"
  description = "port(s) for gameserver"
  vpc_id      = local.vpc_id
}

#Create security group to allow NFS ports for EFS
resource "aws_security_group" "efs_sg" {
  name        = "allow_nfs_ports"
  description = "Allow NFS ports through so EFS can be accessed"
  vpc_id      = local.vpc_id
}

# Dynamic Security Group Rules for Workload
resource "aws_security_group_rule" "workload_sg_rule" {
  for_each = { for idx, rule in local.workload_ports : idx => rule }

  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_block
  ipv6_cidr_blocks  = lookup(each.value, "ipv6_cidr_block", null)
  security_group_id = aws_security_group.ecs_sg.id
}

# Dynamic Security Group Rules for EFS
resource "aws_security_group_rule" "efs_sg_rule" {
  for_each = { for idx, rule in local.efs_ports : idx => rule }

  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_block
  ipv6_cidr_blocks  = lookup(each.value, "ipv6_cidr_block", null)
  security_group_id = aws_security_group.efs_sg.id
}