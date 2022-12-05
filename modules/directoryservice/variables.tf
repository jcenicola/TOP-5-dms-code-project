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

variable "app-subnets" {
  type = list(any)
}

variable "ds_admin" {
  type = string  
}

variable "ds_domain_name" {
  type = string  
}

variable "ds_edition" {
  type = string
}

variable "ds_type" {
  type = string
}