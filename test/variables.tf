variable "aws_profile" {
  #Which AWS profile to use?  E.g. in the .aws/credentials file each profile is
  #preceeded by a [profile name] line. If we're using a non-default one, modify
  #it here.
  default = "alternate"
}

variable "hosted_zone" {
  description = "What's the base hosted zone name before the game specific record"
  #E.g. if you want to use minecraft.game.knowhowit.com, you need to use game.knowhowit.com here
  default = "test.knowhowit.com"
}