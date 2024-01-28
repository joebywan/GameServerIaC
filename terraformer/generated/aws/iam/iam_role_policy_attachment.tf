resource "aws_iam_role_policy_attachment" "tfer--AWS-QuickSetup-StackSet-Local-ExecutionRole_AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = "AWS-QuickSetup-StackSet-Local-ExecutionRole"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSReservedSSO_AdministratorAccess_f02d4e1e00782331_AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = "AWSReservedSSO_AdministratorAccess_f02d4e1e00782331"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSReservedSSO_Billing_b8be766ee003709c_Billing" {
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
  role       = "AWSReservedSSO_Billing_b8be766ee003709c"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSReservedSSO_ReadOnlyAccess_3be028a420bb9f40_ReadOnlyAccess" {
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  role       = "AWSReservedSSO_ReadOnlyAccess_3be028a420bb9f40"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSServiceRoleForAPIGateway_APIGatewayServiceRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/APIGatewayServiceRolePolicy"
  role       = "AWSServiceRoleForAPIGateway"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSServiceRoleForAmazonElasticFileSystem_AmazonElasticFileSystemServiceRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonElasticFileSystemServiceRolePolicy"
  role       = "AWSServiceRoleForAmazonElasticFileSystem"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSServiceRoleForBackup_AWSBackupServiceLinkedRolePolicyForBackup" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSBackupServiceLinkedRolePolicyForBackup"
  role       = "AWSServiceRoleForBackup"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSServiceRoleForEC2Spot_AWSEC2SpotServiceRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSEC2SpotServiceRolePolicy"
  role       = "AWSServiceRoleForEC2Spot"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSServiceRoleForECS_AmazonECSServiceRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonECSServiceRolePolicy"
  role       = "AWSServiceRoleForECS"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSServiceRoleForOrganizations_AWSOrganizationsServiceTrustPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSOrganizationsServiceTrustPolicy"
  role       = "AWSServiceRoleForOrganizations"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSServiceRoleForSSO_AWSSSOServiceRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSSSOServiceRolePolicy"
  role       = "AWSServiceRoleForSSO"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSServiceRoleForSupport_AWSSupportServiceRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSSupportServiceRolePolicy"
  role       = "AWSServiceRoleForSupport"
}

resource "aws_iam_role_policy_attachment" "tfer--AWSServiceRoleForTrustedAdvisor_AWSTrustedAdvisorServiceRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSTrustedAdvisorServiceRolePolicy"
  role       = "AWSServiceRoleForTrustedAdvisor"
}

resource "aws_iam_role_policy_attachment" "tfer--SSM_Access_AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = "SSM_Access"
}

resource "aws_iam_role_policy_attachment" "tfer--SSM_Access_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = "SSM_Access"
}

resource "aws_iam_role_policy_attachment" "tfer--ecs-002E-task-002E-minecraft-server_ecs-002E-rw-002E-minecraft-service" {
  policy_arn = "arn:aws:iam::746627761656:policy/ecs.rw.minecraft-service"
  role       = "ecs.task.minecraft-server"
}

resource "aws_iam_role_policy_attachment" "tfer--ecs-002E-task-002E-minecraft-server_ecs-002E-rw-002E-valheim-service" {
  policy_arn = "arn:aws:iam::746627761656:policy/ecs.rw.valheim-service"
  role       = "ecs.task.minecraft-server"
}

resource "aws_iam_role_policy_attachment" "tfer--ecs-002E-task-002E-minecraft-server_efs-002E-rw-002E-ark-data" {
  policy_arn = "arn:aws:iam::746627761656:policy/efs.rw.ark-data"
  role       = "ecs.task.minecraft-server"
}

resource "aws_iam_role_policy_attachment" "tfer--ecs-002E-task-002E-minecraft-server_efs-002E-rw-002E-minecraft-data" {
  policy_arn = "arn:aws:iam::746627761656:policy/efs.rw.minecraft-data"
  role       = "ecs.task.minecraft-server"
}

resource "aws_iam_role_policy_attachment" "tfer--ecs-002E-task-002E-minecraft-server_efs-002E-rw-002E-valheim-data" {
  policy_arn = "arn:aws:iam::746627761656:policy/efs.rw.valheim-data"
  role       = "ecs.task.minecraft-server"
}

resource "aws_iam_role_policy_attachment" "tfer--ecs-002E-task-002E-minecraft-server_route53-002E-rw-002E-ecs-002E-knowhowit-002E-com" {
  policy_arn = "arn:aws:iam::746627761656:policy/route53.rw.ecs.knowhowit.com"
  role       = "ecs.task.minecraft-server"
}

resource "aws_iam_role_policy_attachment" "tfer--ecs-002E-task-002E-minecraft-server_sns-002E-publish-002E-minecraft-notifications" {
  policy_arn = "arn:aws:iam::746627761656:policy/sns.publish.minecraft-notifications"
  role       = "ecs.task.minecraft-server"
}

resource "aws_iam_role_policy_attachment" "tfer--ecsTaskExecutionRole_AmazonECSTaskExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = "ecsTaskExecutionRole"
}

resource "aws_iam_role_policy_attachment" "tfer--minecraft-launcher-role-k5ykxxb0_AWSLambdaBasicExecutionRole-0db88ec4-e3aa-4e5c-b491-3bcf5dfd0701" {
  policy_arn = "arn:aws:iam::746627761656:policy/service-role/AWSLambdaBasicExecutionRole-0db88ec4-e3aa-4e5c-b491-3bcf5dfd0701"
  role       = "minecraft-launcher-role-k5ykxxb0"
}

resource "aws_iam_role_policy_attachment" "tfer--minecraft-launcher-role-k5ykxxb0_ecs-002E-rw-002E-minecraft-service" {
  policy_arn = "arn:aws:iam::746627761656:policy/ecs.rw.minecraft-service"
  role       = "minecraft-launcher-role-k5ykxxb0"
}

resource "aws_iam_role_policy_attachment" "tfer--minecraft-stopper-role-14395r29_AWSLambdaBasicExecutionRole-be7759c9-c324-403f-9200-016fc1347a61" {
  policy_arn = "arn:aws:iam::746627761656:policy/service-role/AWSLambdaBasicExecutionRole-be7759c9-c324-403f-9200-016fc1347a61"
  role       = "minecraft-stopper-role-14395r29"
}

resource "aws_iam_role_policy_attachment" "tfer--ssm-ec2_AmazonEC2RoleforSSM" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = "ssm-ec2"
}

resource "aws_iam_role_policy_attachment" "tfer--ssm-ec2_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = "ssm-ec2"
}

resource "aws_iam_role_policy_attachment" "tfer--valheim-launcher-role-fjpw23xw_AWSLambdaBasicExecutionRole-04bd7863-6415-48fb-997d-919631a474d3" {
  policy_arn = "arn:aws:iam::746627761656:policy/service-role/AWSLambdaBasicExecutionRole-04bd7863-6415-48fb-997d-919631a474d3"
  role       = "valheim-launcher-role-fjpw23xw"
}

resource "aws_iam_role_policy_attachment" "tfer--valheim-launcher-role-fjpw23xw_ecs-002E-rw-002E-valheim-service" {
  policy_arn = "arn:aws:iam::746627761656:policy/ecs.rw.valheim-service"
  role       = "valheim-launcher-role-fjpw23xw"
}
