#------------------------------------------------------------------------------
#EFS
#------------------------------------------------------------------------------

#Where the game data will be stored
resource "aws_efs_file_system" "efsFileSystem" {
}

#Access point for EFS
resource "aws_efs_access_point" "efsAccessPoint" {
  file_system_id = aws_efs_file_system.efsFileSystem.id
  root_directory {
    path = "/${var.game_name}"
    creation_info {
        owner_gid = "1000"
        owner_uid = "1000"
        permissions = "0755"
    }
  }
  posix_user {
    gid = "1000"
    uid = "1000"
  }
}

#Allow EFS on default security group
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_default_vpc.default_vpc.id
  ingress {
      protocol = "tcp"
      self = true
      from_port = 2049
      to_port = 2049
      cidr_blocks = [aws_default_vpc.default_vpc.cidr_block]
  }
}