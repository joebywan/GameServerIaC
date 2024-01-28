output "aws_ecs_cluster_tfer--minecraft_id" {
  value = "${aws_ecs_cluster.tfer--minecraft.id}"
}

output "aws_ecs_service_tfer--minecraft_minecraft-server_id" {
  value = "${aws_ecs_service.tfer--minecraft_minecraft-server.id}"
}

output "aws_ecs_service_tfer--minecraft_valheim-server_id" {
  value = "${aws_ecs_service.tfer--minecraft_valheim-server.id}"
}

output "aws_ecs_task_definition_tfer--task-definition-002F-minecraft-server_id" {
  value = "${aws_ecs_task_definition.tfer--task-definition-002F-minecraft-server.id}"
}

output "aws_ecs_task_definition_tfer--task-definition-002F-valheim-server_id" {
  value = "${aws_ecs_task_definition.tfer--task-definition-002F-valheim-server.id}"
}
