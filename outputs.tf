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

output "sftp-bucket" {
  value = module.sftp.sftp-bucket
}

output "rds-sftp-role" {
    value = module.iam.rds-sftp-role
}

output "rds-sftp-policy" {
    value = module.iam.rds-sftp-policy
}

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

output "admin" {
    value = module.ds.admin
    sensitive = true
}

# output "rds-instance-address" {
#     value = module.rds.db_instance_address
# }

# output "rds-instance-id" {
#     value = module.rds.db_instance_id
# }

###############################
## SNS module outputs
###############################
# output "haproxy-sns-topic-arn" {
#   value = module.sns.haproxy-sns-topic-arn
# }

# output "docdb-mgmt-sns-topic-arn" {
#   value = module.sns.docdb-mgmt-sns-topic-arn
# }

# output "jump-sns-topic-arn" {
#   value = module.sns.jump-sns-topic-arn
# }

# output "ASG-sns-topic-arn" {
#   value = module.sns.ASG-sns-topic-arn
# }
