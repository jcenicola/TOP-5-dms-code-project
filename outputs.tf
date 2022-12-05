#####################################################
## Deployment's Root outputs.tf. The outputs list
## here were identified in the ./module/*/output.tf
## files. Output "<name>" matches output "<name>" 
## from ./module/*/output.tf
#####################################################

###############################
## Networking module outputs
###############################

output "vpc_id" {
  value = module.network.vpc_id
}

output "public-subnets" {
  value = module.network.public-subnets
}

output "app-subnets" {
  value = module.network.app-subnets
}

output "database-subnets" {
  value = module.network.database-subnets
}

###############################
## SFTP module outputs
###############################

output "sftp-bucket" {
  value = module.sftp.sftp-bucket
}

###############################
## IAM module outputs
###############################

output "rds-sftp-role" {
    value = module.iam.rds-sftp-role
}

output "rds-sftp-policy" {
    value = module.iam.rds-sftp-policy
}

###############################
## Instances module outputs
###############################

output "ec2-instance-profile" {
    value = module.iam.ec2-instance-profile
}

output "rds-ad-role" {
    value = module.iam.rds-ad-role
}

output "rds-ad-policy" {
    value = module.iam.rds-ad-policy
}

output "public-sg" {
  value = module.network.public-sg
}

output "app-sg" {
  value = module.network.app-sg
}

output "database-sg" {
  value = module.network.database-sg
}

output "ec2instance-private_dns" {
    value = module.instances.ec2instance-private_dns
}

output "target-endpoint" {
    value = module.rds.target-endpoint
}

####################################
## Directory Service module outputs
####################################

output "ds-id" {
    value = module.ds.ds-id
}

output "ds-dns" {
    value = module.ds.ds-dns
}

output "ds-name" {
    value = module.ds.ds-name
}

####################################
## Secerts Manager module outputs
####################################

output "ds_admin" {
    value = module.sm.ds_admin
    sensitive = true
}

output "awssct" {
    value = module.sm.awssct
    sensitive = true
}
