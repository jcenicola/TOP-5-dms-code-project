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

variable "sftp-bucket" {
  type = string  
}

variable "environment" {
  type = string
}