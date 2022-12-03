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

variable "rds-ad-role" {
  type = string
}

variable "ds-id" {
  type = string
}
