#####################################################
## Deployment's Root variables.tf. The variable 
## blockes listed here are full blocks with default
## values. Variable <name> and type must match the
## variables identified in ./module/*/variables.tf 
## files.
#####################################################

###############################
## General code wide variables
###############################

variable "namespace" {
  description = "The project namespace to use for unique resource naming"
  type        = string
  default     = "team1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

###############################
## Networking variables
###############################

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC cidr"
}

variable "azs" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public-subnets" {
  type        = list(any)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "Public subnet cidr"
}

variable "app-subnets" {
  type        = list(any)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  description = "haproxy private subnet cidr"
}

variable "database-subnets" {
  type        = list(any)
  default     = ["10.0.111.0/24", "10.0.122.0/24", "10.0.133.0/24"]
  description = "app private subnet cidr"
}

###############################
## Instances variables
###############################

variable "jump_instance_type" {
  description = "windows jump server"
  default     = "t2.small"
}

variable "win_instance_type" {
  description = "Windows server type"
  default     = "c5.xlarge"
}

variable "volume_size" {
  description = "EBS volume for instance."
  default     = "500"
}

# Machine Images

variable "win-server-2019" {
  description = "Windows 2019 Base 64 AMI"
  default     = "ami-06371c9f2ad704460"
}

variable "sql-database-server" {
  
  description = "Source - SQL databases server" 
  default     = "ami-03682cbe3aba12927" 
  ## this is an aws community ami in us-east-1 for AWS-DMS Workshop.  
}

# Instance Key Pair
variable "key_pair" {
  description = "Key Pair name"
  default     = "dms"
}

###############################
## sftp variables
###############################

variable "sftp-bucket" {
  type = string  
  default = "sftp-bucket-top"
}

###############################
## RDS variables
###############################

variable "rds_username" {
  type = string  
  default = "awssct"
}

variable "engine" {
  type = string  
  default = "sqlserver-se"
}

variable "engine_version" {
  type = string  
  default = "15.00.4073.23.v1"
}

variable "instance_class" {
  type = string  
  default = "db.r5.xlarge"
}

###############################
## DMS variables
###############################

variable "dms_allocated_storage" {
  type = string
  default = "50"
}         
  
variable "dms_multi_az" {
  type = string
  default = "false"
}                    

variable "replication_instance_class" {
  type = string  
  default = "dms.c5.xlarge"
}

variable "source_username" {
  type = string  
  default = "awssct"
}

variable "source_database_name" {
  type = string  
  default = "dms_sample"
}

variable "target_username" {
  type = string  
  default = "awssct"
}

variable "target_database_name" {
  type = string  
  default = "targetdb"
}

###################################
## Directory service Variables
###################################

variable "ds_domain_name" {
  type = string  
  default = "team1.com"
}

variable "ds_edition" {
  type = string
  default = "Standard"
}

variable "ds_type" {
  type = string
  default = "MicrosoftAD"
}