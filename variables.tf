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

variable "public-subnets" {
  type    = list(any)
  default = []
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

###############################
## Instances variables
###############################

variable "jump_instance_type" {
  description = "windows jump server"
  default     = "t2.small"
}

variable "volume_size" {
  description = "EBS volume for instance."
  default     = "500"
}

# Machine Images

variable "win-server-2019" {
  description = "Windows 2019 Base 64"
  default     = "ami-06371c9f2ad704460"
}

variable "key_pair" {
  description = "Key Pair name"
  default     = "dms"
}
