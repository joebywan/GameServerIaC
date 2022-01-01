resource "aws_efs_file_system" "efsFileSystem" {
}

resource "aws_efs_access_point" "efsAccessPoint" {
  file_system_id = aws_efs_file_system.efsFileSystem
  root_directory {
    path = "/minecraft"
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

output "efs_id" {
    value = aws_efs_file_system.efsFileSystem.id
}

output "efs_ap_id" {
  value = aws_efs_access_point.efsAccessPoint.id
}