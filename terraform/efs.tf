#------------------------------------------------------------------------------
#EFS
#------------------------------------------------------------------------------

#Where the game data will be stored
resource "aws_efs_file_system" "efsFileSystem" {
}

# Exposes the EFS to each subnet in the VPC.  Makes sure there's 1 per AZ
resource "aws_efs_mount_target" "mount_target" {
  count           = length(tolist(data.aws_subnet_ids.defaultVPCSubnetIds.ids))
  file_system_id  = aws_efs_file_system.efsFileSystem.id
  subnet_id       = tolist(data.aws_subnet_ids.defaultVPCSubnetIds.ids)[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

#Access point for EFS
resource "aws_efs_access_point" "efsAccessPoint" {
  file_system_id = aws_efs_file_system.efsFileSystem.id
  root_directory {
    path = "/${var.game_name}"
    creation_info {
      owner_gid   = "1000"
      owner_uid   = "1000"
      permissions = "0755"
    }
  }
  posix_user {
    gid = "1000"
    uid = "1000"
  }
}