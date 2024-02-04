resource "aws_ecs_service" "this" {
  depends_on = [aws_ecs_cluster.this, aws_ecs_task_definition.this]
  capacity_provider_strategy {
    base              = "0"
    capacity_provider = "FARGATE_SPOT"
    weight            = "1"
  }

  cluster = aws_ecs_cluster.this.name

  deployment_circuit_breaker {
    enable   = "false"
    rollback = "false"
  }

  deployment_controller {
    type = "ECS"
  }
  # iam_role                           = aws_iam_role.ecs_service_role.arn
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = "0"
  enable_ecs_managed_tags            = "false"
  enable_execute_command             = "false"
  health_check_grace_period_seconds  = "0"
  name                               = "${local.workload_name}_service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = data.aws_subnets.this.ids
  }

  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"

  task_definition = aws_ecs_task_definition.this.family

  lifecycle {
      ignore_changes = [
        task_definition,
        desired_count
      ]
  }
}
