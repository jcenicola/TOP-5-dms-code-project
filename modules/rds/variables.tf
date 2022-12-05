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

variable "awssct" {
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

variable "rds_username" {
  type = string  
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}
