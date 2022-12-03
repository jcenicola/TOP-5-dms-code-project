#####################################################
## Deployment's Root version.tf. This identify's 
## required version of terraform to use and the
## required provider block (name, source, version)
#####################################################

terraform {
  required_version = ">= 0.15"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}