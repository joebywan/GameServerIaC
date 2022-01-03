#data source for current user information.  Used to get current account id
data "aws_caller_identity" "current" { 
}

#data source to show the region of the current provider in use
data "aws_region" "current" {
}