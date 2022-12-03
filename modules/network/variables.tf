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

variable "vpc_cidr" {
  type = string
}

variable "public-subnets" {
  type = list(any)
}

variable "app-subnets" {
  type = list(any)
}

variable "database-subnets" {
  type = list(any)
}

variable "database-sg" {
  type =  string 
}

variable "azs" {
  type = list(any)
}

