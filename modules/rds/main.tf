################################################################################
# RDS Module
################################################################################

# resource "aws_db_subnet_group" "rds" {
#   name       = "rds-subent-group"
#   subnet_ids = [var.database-subnets[0], var.database-subnets[1], var.database-subnets[2]]

#   tags = {
#     Name = "My DB subnet group"
#   }
# }

# resource "aws_db_instance" "default" {
  # allocated_storage       = 100
#   license_model           = "license-included"
  # engine                  = "sqlserver-se"
#   engine_version          = "15.00.4073.23.v1"
  # instance_class          = "db.r5.xlarge"
#   iops                    = "2000"
  # username                = "awssct"
  # password                = "Password1"
#   backup_retention_period = 0
#   skip_final_snapshot     = true
#   vpc_security_group_ids  = [var.database-sg]
#   db_subnet_group_name    = aws_db_subnet_group.rds.name
#   # depends_on = [
#   #   aws_security_group.rds_security_group
#   # ]
# }


module "rds" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "mssqldb"

  engine               = "sqlserver-ee"
  # engine_version       = "15.00.4236.7.v1"
  license_model        = "license-included"
  instance_class       = "db.m6i.xlarge"
  # iops                 = "2000"
  allocated_storage     = 20
  max_allocated_storage = 200
  storage_encrypted     = false
  family               = "sqlserver-ee-15.0" # DB parameter group
  major_engine_version = "15.00"             # DB option group

  username                = "awssct"
  password                = "Password1"
  port                    = 1433

  multi_az               = false
  create_db_subnet_group = true
  subnet_ids             = [var.database-subnets[0], var.database-subnets[1], var.database-subnets[2]]
  vpc_security_group_ids = [var.database-sg]

  #enabled_cloudwatch_logs_exports = ["error"]
  #create_cloudwatch_log_group     = true
  
  domain               = var.ds-id
  domain_iam_role_name = var.rds-ad-role

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  
  timezone                  = "Central Standard Time"   # Microsoft SQL server only
  # character_set_name        = "Latin1_General_CI_AS"  # DB encoding in Oracle instances


  tags = {
    Name = "${terraform.workspace}-${var.region}-rds-target"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
    }
}

