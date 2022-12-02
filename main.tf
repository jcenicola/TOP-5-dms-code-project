variable "testname" {
  type    = string
  default = "test"
}

data "aws_availability_zones" "available" {
  state = "available"
}