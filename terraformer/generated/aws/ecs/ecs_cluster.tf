resource "aws_ecs_cluster" "tfer--minecraft" {
  name = "minecraft"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
