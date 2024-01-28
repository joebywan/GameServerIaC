resource "aws_ecs_cluster" "this" {
  name = "${local.workload_name}_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
