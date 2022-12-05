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

variable "dms_allocated_storage" {
  type = string
}         
  
variable "dms_multi_az" {
  type = string
}                    

variable "replication_instance_class" {
  type = string  
}

variable "source_username" {
  type = string  
}

variable "source_database_name" {
  type = string  
}

variable "target_username" {
  type = string  
}

variable "target_database_name" {
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