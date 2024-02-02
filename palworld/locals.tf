locals {
  workload_name           = "palworld"
  workload_region         = "ap-southeast-2"
  workload_port           = 8211
  workload_protocol       = "udp"
  workload_password       = "worldofpals"
  workload_admin_password = "someAdminPassword"
  workload_rcon_port      = 25575

  vpc_id          = "vpc-0b774b4479ea3baa6"
  hosted_zone     = "ecs.knowhowit.com"
  efs_name        = "minecraftStore"
  lambda_location = "scripts/lambda_function.py"

  workload_ports = [
    {
      type       = "ingress"
      from_port  = local.workload_port
      to_port    = local.workload_port
      protocol   = local.workload_protocol
      cidr_block = ["0.0.0.0/0"]
    },
    # {
    #   type       = "ingress"
    #   from_port  = local.workload_rcon_port
    #   to_port    = local.workload_rcon_port
    #   protocol   = "tcp"
    #   cidr_block = ["0.0.0.0/0"]
    # },
    {
      type       = "ingress"
      from_port  = 27015
      to_port    = 27015
      protocol   = "udp"
      cidr_block = ["0.0.0.0/0"]
    },
    {
      type            = "egress"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_block      = ["0.0.0.0/0"]
      ipv6_cidr_block = ["::/0"]
    }
  ]
  efs_ports = [
    {
      type       = "ingress"
      from_port  = 2049
      to_port    = 2049
      protocol   = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },
    {
      type            = "egress"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_block      = ["0.0.0.0/0"]
      ipv6_cidr_block = ["::/0"]
    }
  ]

  default_tags = {
    Workload    = local.workload_name
    DeployedVia = "Terraform"
  }


  workload_container = {
    name      = "${local.workload_name}-server"
    image     = "thijsvanloef/palworld-server-docker:v0.18"
    cpu       = 0
    essential = true
    "environment" : [
      { "name" : "PORT", "value" : "8211" },
      { "name" : "PUID", "value" : "1000" },
      { "name" : "PGID", "value" : "1000" },
      { "name" : "PLAYERS", "value" : "16" },
      { "name" : "DEATH_PENALTY", "value" : "1" },
      { "name" : "PAL_EGG_DEFAULT_HATCHING_TIME", "value" : "0.1" },
      { "name" : "BACKUP_ENABLED", "value" : "TRUE" },
      { "name" : "MULTITHREADING", "value" : "TRUE" },
      { "name" : "RCON_ENABLED", "value" : "TRUE" },
      { "name" : "RCON_PORT", "value" : tostring(local.workload_rcon_port) },
      # { "name" : "COMMUNITY", "value" : "false" }, # Do you want it added to the server list or not?
      # Uncomment and add the following lines if COMMUNITY is set to "true"
      { "name" : "SERVER_PASSWORD", "value" : local.workload_password },
      { "name" : "SERVER_NAME", "value" : "Damage Inc Palworld Server" },
      { "name" : "ADMIN_PASSWORD", "value" : local.workload_admin_password },
      { "name" : "TZ", "value" : "Australia/Brisbane" },
    ],
    portMappings = [for port in local.workload_ports : { # won't work with ranges
      containerPort = port.from_port
      hostPort      = port.from_port
      protocol      = port.protocol
      } if port.type == "ingress"
    ]
    mountPoints = [
      { containerPath = "/palworld", sourceVolume = "${local.workload_name}-efs_volume" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${local.workload_name}-server"
        awslogs-region        = "ap-southeast-2"
        awslogs-stream-prefix = "ecs"
      }
    }
  }

  ecswatcher_container = {
    name      = "ecswatcher"
    image     = "joebywan/palworldecswatchersidecart:0.1"
    cpu       = 0
    essential = true
    environment = [
      { "name" : "DNSADDRESS", "value" : "${local.workload_name}.${local.hosted_zone}" },
      { "name" : "DNSZONE", "value" : data.aws_route53_zone.this.zone_id },
      { "name" : "STARTUPMIN", "value" : "10" },  # Numbers must be strings
      { "name" : "SHUTDOWNMIN", "value" : "20" }, # Numbers must be strings
      { "name" : "HOST", "value" : "127.0.0.1" },
      { "name" : "PORT", "value" : tostring(local.workload_rcon_port) }, # Numbers must be strings
      { "name" : "ADMINPASSWORD", "value" : local.workload_admin_password },
      { "name" : "SNSTOPIC", "value" : "arn:aws:sns:ap-southeast-2:746627761656:minecraft-notifications" },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${local.workload_name}-watchdog"
        awslogs-region        = "ap-southeast-2"
        awslogs-stream-prefix = "ecs"
      }
    }
  }
}