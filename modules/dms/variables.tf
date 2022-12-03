############################################
##  List of variables and type
##  defaults (values) are set in 
##  root variables.tf
############################################

variable "namespace" {
    type = string
}

variable "region" {
  type = string
}

variable "database-subnets" {
   type = list(any)
 }

variable "database-sg" {
  type = string
}

variable "target-endpoint" {
  type = string
}

variable "ec2instance-private_dns" {
    type = string
}