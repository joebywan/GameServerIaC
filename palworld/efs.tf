#Access point for EFS
resource "aws_efs_access_point" "this" {
  file_system_id = data.aws_efs_file_system.this.file_system_id
  root_directory {
    path = "/${local.workload_name}"
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