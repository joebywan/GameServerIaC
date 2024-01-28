#Access point for EFS
resource "aws_efs_access_point" "this" {
  file_system_id = "fs-077194a1fef069da3"
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