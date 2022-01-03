#------------------------------------------------------------------------------
#ECS
#------------------------------------------------------------------------------
#----- ECS cluster -----
resource "aws_ecs_cluster" "ecs_cluster" {
  name               = "${var.game_name}"
  capacity_providers = ["FARGATE_SPOT"]

  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }
}

#----- ECS Service -----
resource "aws_ecs_service" "minecraft_ondemand_service" {
  name            = "${var.game_name}-server"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.game_server_and_watchdog.arn
  desired_count   = 0
  #   iam_role        = aws_iam_role.minecraft_ondemand_fargate_task_role.arn
  # depends_on             = [aws_iam_policy.minecraft_ondemand_efs_access_policy]
  enable_execute_command = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_az[0].id, aws_default_subnet.default_az[1].id, aws_default_subnet.default_az[2].id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

#----- ECS Task -----
resource "aws_ecs_task_definition" "game_server_and_watchdog" {
  family = "${var.game_name}-server"

  requires_compatibilities = [
    "FARGATE"
  ]
  memory = 2048
  cpu = 1024
  network_mode = "awsvpc"

  container_definitions = jsonencode(
    [
      {
        name      = "${var.game_name}-server"
        image     = "itzg/minecraft-server"

        essential = false
        portMappings = [
          {
            protocol = "tcp"
            containerPort = 25565
            hostPort      = 25565
          }
        ]
        environment = [
          {
            name = "EULA"
            value = "TRUE"
          }
        ]
        mountpoints = [
          {
            sourceVolume = "data"
            containerPath = "/data"
          }
        ]
      },
      {
        name      = "${var.game_name}-ecsfargate-watchdog"
        image     = "doctorray/minecraft-ecsfargate-watchdog"
        cpu       = 10
        memory    = 256
        essential = true
        environment = [
          {
            name = "CLUSTER"
            value = "${var.game_name}"
          },
          {
            name = "SERVICE"
            value = "{$var.game_name}-server"
          },
          {
            name = "DNSZONE"
            value = aws_route53_zone.public_hosted_zone.id
          },
          {
            name = "SERVERNAME"
            value = "${var.game_name}.${var.hosted_zone}"
          },
          {
            name = "STARTUPMIN"
            value = "10"
          },
          {
            name = "SHUTDOWNMIN"
            value = "20"
          },
          {
            name = "SNSTOPIC"
            value = aws_sns_topic.server_status_updates.arn
          }
        ]
      }
    ]
  )

  volume {
    name      = "data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efsFileSystem.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.efsAccessPoint.id
        iam = "ENABLED"
      }
    }
  }
}