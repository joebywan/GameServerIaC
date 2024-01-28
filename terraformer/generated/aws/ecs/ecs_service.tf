resource "aws_ecs_service" "tfer--minecraft_minecraft-server" {
  capacity_provider_strategy {
    base              = "0"
    capacity_provider = "FARGATE_SPOT"
    weight            = "1"
  }

  cluster = "minecraft"

  deployment_circuit_breaker {
    enable   = "false"
    rollback = "false"
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = "0"
  enable_ecs_managed_tags            = "true"
  enable_execute_command             = "false"
  health_check_grace_period_seconds  = "0"
  name                               = "minecraft-server"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = ["sg-07722a8d8ce35f431"]
    subnets          = ["subnet-0400a0e6fcf46a76f", "subnet-075d403197fd04b82", "subnet-0ce4494e5ca93063b"]
  }

  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"
  task_definition     = "arn:aws:ecs:ap-southeast-2:746627761656:task-definition/minecraft-server:4"
}

resource "aws_ecs_service" "tfer--minecraft_valheim-server" {
  capacity_provider_strategy {
    base              = "0"
    capacity_provider = "FARGATE_SPOT"
    weight            = "1"
  }

  cluster = "minecraft"

  deployment_circuit_breaker {
    enable   = "false"
    rollback = "false"
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = "0"
  enable_ecs_managed_tags            = "false"
  enable_execute_command             = "false"
  health_check_grace_period_seconds  = "0"
  name                               = "valheim-server"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = ["sg-0ebdd517df1258288"]
    subnets          = ["subnet-0400a0e6fcf46a76f", "subnet-075d403197fd04b82", "subnet-0ce4494e5ca93063b"]
  }

  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"

  tags = {
    manual = "true"
    server = "valheim"
  }

  tags_all = {
    manual = "true"
    server = "valheim"
  }

  task_definition = "arn:aws:ecs:ap-southeast-2:746627761656:task-definition/valheim-server:5"
}
