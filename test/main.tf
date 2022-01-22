data "aws_availability_zones" "listofaz" {

}

output "name" {
  value = data.aws_availability_zones.listofaz.names
}