resource "aws_ecs_task_definition" "tfer--task-definition-002F-minecraft-server" {
  container_definitions    = "[{\"cpu\":0,\"environment\":[{\"name\":\"ENFORCE_WHITELIST\",\"value\":\"true\"},{\"name\":\"EULA\",\"value\":\"true\"},{\"name\":\"OPS\",\"value\":\"joehowe,kaylene,benbengold\"},{\"name\":\"OVERRIDE_OPS\",\"value\":\"true\"},{\"name\":\"WHITELIST\",\"value\":\"joehowe,kaylene,benbengold\"}],\"essential\":false,\"image\":\"itzg/minecraft-server\",\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"/ecs/minecraft-server\",\"awslogs-region\":\"ap-southeast-2\",\"awslogs-stream-prefix\":\"ecs\"}},\"mountPoints\":[{\"containerPath\":\"/data\",\"sourceVolume\":\"data\"}],\"name\":\"minecraft-server\",\"portMappings\":[{\"containerPort\":25565,\"hostPort\":25565,\"protocol\":\"tcp\"}],\"volumesFrom\":[]},{\"cpu\":0,\"environment\":[{\"name\":\"CLUSTER\",\"value\":\"minecraft\"},{\"name\":\"DNSZONE\",\"value\":\"Z01039561OO2DM57CFK0S\"},{\"name\":\"SERVERNAME\",\"value\":\"minecraft.ecs.knowhowit.com\"},{\"name\":\"SERVICE\",\"value\":\"minecraft-server\"},{\"name\":\"SNSTOPIC\",\"value\":\"arn:aws:sns:ap-southeast-2:746627761656:minecraft-notifications\"}],\"essential\":true,\"image\":\"doctorray/minecraft-ecsfargate-watchdog\",\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"/ecs/minecraft-server\",\"awslogs-region\":\"ap-southeast-2\",\"awslogs-stream-prefix\":\"ecs\"}},\"mountPoints\":[],\"name\":\"minecraft-ecsfargate-watchdog\",\"portMappings\":[],\"volumesFrom\":[]}]"
  cpu                      = "1024"
  execution_role_arn       = "arn:aws:iam::746627761656:role/ecsTaskExecutionRole"
  family                   = "minecraft-server"
  memory                   = "2048"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = "arn:aws:iam::746627761656:role/ecs.task.minecraft-server"

  volume {
    efs_volume_configuration {
      authorization_config {
        access_point_id = "fsap-056ef92067cabb1cb"
        iam             = "DISABLED"
      }

      file_system_id          = "fs-077194a1fef069da3"
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = "0"
    }

    name = "data"
  }
}

resource "aws_ecs_task_definition" "tfer--task-definition-002F-valheim-server" {
  container_definitions    = "[{\"cpu\":0,\"dockerLabels\":{\"manual\":\"true\",\"server\":\"valheim\"},\"environment\":[{\"name\":\"SERVER_NAME\",\"value\":\"My Server\"},{\"name\":\"SERVER_PASS\",\"value\":\"DamageInc\"},{\"name\":\"WORLD_NAME\",\"value\":\"world1\"}],\"essential\":true,\"image\":\"ghcr.io/lloesche/valheim-server\",\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"/ecs/valheim-server\",\"awslogs-region\":\"ap-southeast-2\",\"awslogs-stream-prefix\":\"ecs\"}},\"mountPoints\":[{\"containerPath\":\"/config\",\"sourceVolume\":\"valheim-config\"},{\"containerPath\":\"/opt/valheim\",\"sourceVolume\":\"valheim-server\"}],\"name\":\"valheim-server\",\"portMappings\":[{\"containerPort\":2456,\"hostPort\":2456,\"protocol\":\"udp\"},{\"containerPort\":2457,\"hostPort\":2457,\"protocol\":\"udp\"}],\"volumesFrom\":[]},{\"cpu\":0,\"environment\":[{\"name\":\"CLUSTER\",\"value\":\"minecraft\"},{\"name\":\"DNSZONE\",\"value\":\"Z01039561OO2DM57CFK0S\"},{\"name\":\"QUERYPORT\",\"value\":\"2457\"},{\"name\":\"SERVERNAME\",\"value\":\"valheim.ecs.knowhowit.com\"},{\"name\":\"SERVICE\",\"value\":\"valheim-server\"},{\"name\":\"SHUTDOWNMIN\",\"value\":\"20\"},{\"name\":\"SNSTOPIC\",\"value\":\"arn:aws:sns:ap-southeast-2:746627761656:minecraft-notifications\"},{\"name\":\"STARTUPMIN\",\"value\":\"10\"}],\"essential\":true,\"image\":\"joebywan/valheimecswatcher\",\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"/ecs/valheim-server\",\"awslogs-region\":\"ap-southeast-2\",\"awslogs-stream-prefix\":\"ecs\"}},\"mountPoints\":[],\"name\":\"ecswatcher\",\"portMappings\":[],\"volumesFrom\":[]}]"
  cpu                      = "2048"
  execution_role_arn       = "arn:aws:iam::746627761656:role/ecsTaskExecutionRole"
  family                   = "valheim-server"
  memory                   = "4096"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
  }

  tags = {
    manual = "true"
    server = "valheim"
  }

  tags_all = {
    manual = "true"
    server = "valheim"
  }

  task_role_arn = "arn:aws:iam::746627761656:role/ecs.task.minecraft-server"

  volume {
    efs_volume_configuration {
      authorization_config {
        access_point_id = "fsap-08d5b3c7a541487d5"
        iam             = "DISABLED"
      }

      file_system_id          = "fs-077194a1fef069da3"
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = "0"
    }

    name = "valheim-server"
  }

  volume {
    efs_volume_configuration {
      authorization_config {
        access_point_id = "fsap-096e684cfe8e14cb2"
        iam             = "DISABLED"
      }

      file_system_id          = "fs-077194a1fef069da3"
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = "0"
    }

    name = "valheim-config"
  }
}
