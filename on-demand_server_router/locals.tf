locals {
  workload_name           = "on-demand_server_router"
  source_log_group_name = "/aws/route53/ecs.knowhowit.com"
  filter_pattern = "[,,,url=\"minecraft.ecs.knowhowit.com\" || url=\"valheim.ecs.knowhowit.com\" || url=\"palworld.ecs.knowhowit.com\",...]"
  workload_region = "us-east-1"

  service_mapping = {
    "minecraft" = { "cluster" = "minecraft", "service" = "minecraft-server", "region" = "ap-southeast-2" },
    "valheim"   = { "cluster" = "minecraft", "service" = "valheim-server", "region" = "ap-southeast-2" },
    "palworld"  = { "cluster" = "palworld_cluster", "service" = "palworld-service", "region" = "ap-southeast-2" }
    # Add more mappings as needed
  }

  default_tags = {
    Workload    = local.workload_name
    DeployedVia = "Terraform"
    Repo = "insert_here"
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
