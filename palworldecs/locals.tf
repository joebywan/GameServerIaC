locals {
    region = "ap-southeast-2"
    name   = "palworld}"

    vpc_cidr = "10.0.0.0/16"
    azs      = slice(data.aws_availability_zones.available.names, 0, 3)
    
    container_name = "ecsdemo-frontend"
    container_port = 3000
    main_container = {
        name = "palworld"
        port = 27015
        image = "hmes98318/palworld-docker:latest"
        cpu = 1024
        memory = 2048
        environment_vars = {
            timezone = "Australia/Brisbane"
            ports = [
              8211,
              27015,
              27016,
              25575
            ]
        }
    }
    watcher_container = {
        name = "ecswatcher"
        image = "joebywan/valheimecswatcher"
        cpu = 
    }
    tags = {
        Name       = local.name
        Example    = local.name
        Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
    }
}