variable "hosted_zone" {
  description = "What's the base hosted zone name before the game specific record"
  #E.g. if you want to use minecraft.game.knowhowit.com, you need to use game.knowhowit.com here
  default = "game.knowhowit.com"  
}

variable "game_name" {
  description = "What is the game called?"
  default = "minecraft"
}

variable "lambda_location" {
  description = "Where's the lambda function file?"
  default = "./lambda_function.py"
}

variable "az_suffix" {
  description = "Provides the availability zone designator"
  default = ["a","b","c"]
}

variable "ecsports" {
  description = "ports required for the game being installed"
  type = list(
    object(
      {
        type = string
        from_port = number
        to_port = number
        protocol = string
      }
    )
  )
  default = [
    {
      type = "ingress"
      from_port = "25565"
      to_port = "25565"
      protocol = "tcp"
    }
  ]
}