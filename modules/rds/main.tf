################################################################################
# RDS Module
################################################################################

 resource "aws_db_subnet_group" "rds" {
   name       = "rds-subent-group"
   subnet_ids = [var.database-subnets[0], var.database-subnets[1], var.database-subnets[2]]
   tags = {
     Name = "My DB subnet group"
   }
 }
 resource "aws_db_instance" "default" {
   allocated_storage       = 100
   license_model           = "license-included"
   engine                  = var.engine
   engine_version          = var.engine_version
   instance_class          = var.instance_class
   iops                    = "2000"
   username                = var.rds_username
   password                = var.awssct
   backup_retention_period = 0
   skip_final_snapshot     = true
   vpc_security_group_ids  = [var.database-sg]
   db_subnet_group_name    = aws_db_subnet_group.rds.name
   domain               = var.ds-id
   domain_iam_role_name = var.rds-ad-role
    depends_on = [
      aws_db_subnet_group.rds
    ]
 }
