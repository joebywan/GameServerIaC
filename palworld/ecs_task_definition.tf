

resource "aws_ecs_task_definition" "this" {
  depends_on            = [aws_ecs_cluster.this]
  container_definitions = jsonencode([local.workload_container, local.ecswatcher_container])
  # container_definitions    = jsonencode([local.workload_container])
  cpu                      = 2048
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  family                   = "${local.workload_name}_server"
  memory                   = 16384
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
  }

  task_role_arn = aws_iam_role.ecs_task_role.arn

  volume {
    efs_volume_configuration {
      authorization_config {
        access_point_id = aws_efs_access_point.this.id
        iam             = "DISABLED"
      }

      file_system_id          = data.aws_efs_file_system.this.file_system_id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = "0"
    }

    name = "${local.workload_name}-efs_volume"
  }
}
