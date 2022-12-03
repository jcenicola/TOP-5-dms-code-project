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

variable "vpc_id" {
  type = string
}

variable "azs" {
  type = list(any)
}

variable "public-subnets" {
  type = list(any)
}

variable "app-subnets" {
  type = list(any)
}

variable "public-sg" {
  type = string
}

variable "app-sg" {
  type = string
}

variable "jump_instance_type" {
  type = string
}

variable "win_instance_type" {
  type = string
}

variable "ec2-instance-profile" {
  type = string
}

variable "volume_size" {
  type = string
}

variable "sql-database-server" {
  type = string
}

variable "win-server-2019" {
  type = string
}

variable "key_pair" {
  type = string
}
