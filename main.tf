


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.22.0/24"]
  database_subnets = ["10.0.111.0/24", "10.0.122.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = var.environment
  }
}

#########################################################
## EC2 instance role
#########################################################

resource "aws_iam_role" "role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

#################################################
## IAM Policy for instances
#################################################

resource "aws_iam_policy" "policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "ec2:*"          
        Effect = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
                "ds:CreateComputer",
                "ds:DescribeDirectories"
            ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
                "s3:GetBucketLocation",
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",              
                "s3:GetEncryptionConfiguration",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads"
            ],
        Resource = "*"
      }
      
    ]
   }
  )
}

#########################################################
## EC2 session manager Role Policy attachment
#########################################################
resource "aws_iam_role_policy_attachment" "attach_ssm_role" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

#########################################################
## EC2 instance profile role
#########################################################

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "${var.region}-ec2-instance-profile"
  role = aws_iam_role.role.name
}

#########################################################
##  IAM Role for rds-sftp and trust
#########################################################

resource "aws_iam_role" "rds-sftp-role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Sid = ""
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
              "transfer.amazonaws.com",
              "rds.amazonaws.com"
            ]
          }
        }
      ]
      Version = "2012-10-17"
    }
  )
  description           = "Allow AWS Transfer to call AWS services on your behalf."
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "${var.region}-sftp-transfer-role"
  path                  = "/"
}

#################################################
## IAM Policy for rds-sftp
#################################################

resource "aws_iam_policy" "rds-sftp-policy" {
  name = "${var.region}-sftp-transfer-policy"
  path = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:ListBucket",
          ]
          Effect = "Allow"
          Resource = "${aws_s3_bucket.sftp.arn}"
          Sid = "AllowListingOfUserFolder"
        },
        {
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:DeleteObjectVersion",
            "s3:GetBucketLocation",
            "s3:GetObjectVersion",
            "s3:GetObjectACL",
            "s3:PutObjectACL",
          ]
          Effect   = "Allow"
          Resource = "${aws_s3_bucket.sftp.arn}/*"
          Sid      = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
}

#########################################################
## IAM Attach Policy rds-sftp
#########################################################

resource "aws_iam_policy_attachment" "policy-attach" {
  name       = "${var.region}-sftp policy attachment"
  roles      = [aws_iam_role.rds-sftp-role.name]
  policy_arn = aws_iam_policy.rds-sftp-policy.arn
}

##################################################
## S3 Bucket Creation for sftp (family-transfer)
##################################################

resource "aws_s3_bucket" "sftp" {
  bucket = "${var.namespace}-sftp-bucket"
  tags = {
    Name        = "${var.namespace}-sftp-bucket"
    Project = "${var.namespace}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_acl" "sftp" {
  bucket = aws_s3_bucket.sftp.id
  acl    = "private"
}

#########################################################
## Enable AWS Transfer Family (SFTP Service Managed)
#########################################################

resource "aws_transfer_server" "service_managed" {
  endpoint_type          = "PUBLIC"
  identity_provider_type = "SERVICE_MANAGED"
  tags = {
    Name = "${var.region}-sftp-service"
    Project = "${var.namespace}"
    environment = var.environment
    }

}

#########################################################
## Create Security Groups for Instances
#########################################################

resource "aws_security_group" "public-sg" {
  name        = "${var.region}-public-sg"
  description = "Allow public access to jump"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.region}-public-sg"
    Project = "${var.namespace}"
    environment = var.environment
  }
}

data "aws_subnets" "public" {
  depends_on = [
  module.vpc
] 
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }

  tags = {
    Tier = "Public"
  }
}

#########################################################
## Deploy jump-box Instances 
#########################################################

resource "aws_instance" "jump-server" {
  depends_on = [
  module.vpc
]
  ami                    = var.win-server-2019
  instance_type          = var.jump_instance_type
  key_name               = var.key_pair
  for_each               = toset(data.aws_subnets.public.ids)
  subnet_id              = each.value
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.public-sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.id
  
    tags = {
    Name = "${var.region}-jump-server"
    Project = "${var.namespace}"
    environment = var.environment
    }
}

################################################################################
# RDS Module
################################################################################

# module "db" {
#   source = "../../"

#   identifier = local.name

#   engine               = "sqlserver-ex"
#   engine_version       = "15.00.4153.1.v1"
#   family               = "sqlserver-ex-15.0" # DB parameter group
#   major_engine_version = "15.00"             # DB option group
#   instance_class       = "db.t3.large"

#   allocated_storage     = 20
#   max_allocated_storage = 100

#   # Encryption at rest is not available for DB instances running SQL Server Express Edition
#   storage_encrypted = false

#   username = "admin"
#   port     = 1433

#   domain               = aws_directory_service_directory.demo.id
#   domain_iam_role_name = aws_iam_role.rds_ad_auth.name

#   multi_az               = false
#   subnet_ids             = module.vpc.database_subnets
#   vpc_security_group_ids = [module.security_group.security_group_id]

#   maintenance_window              = "Mon:00:00-Mon:03:00"
#   backup_window                   = "03:00-06:00"
#   enabled_cloudwatch_logs_exports = ["error"]
#   create_cloudwatch_log_group     = true

#   backup_retention_period = 1
#   skip_final_snapshot     = true
#   deletion_protection     = false

#   performance_insights_enabled          = true
#   performance_insights_retention_period = 7
#   create_monitoring_role                = true
#   monitoring_interval                   = 60

#   options                   = []
#   create_db_parameter_group = false
#   license_model             = "license-included"
#   timezone                  = "GMT Standard Time"
#   character_set_name        = "Latin1_General_CI_AS"

#   tags = local.tags
# }

# module "db_disabled" {
#   source = "../../"

#   identifier = "${local.name}-disabled"

#   create_db_instance        = false
#   create_db_parameter_group = false
#   create_db_option_group    = false
# }

# ################################################################################
# # RDS Automated Backups Replication Module
# ################################################################################
# provider "aws" {
#   alias  = "region2"
#   region = local.region2
# }

# module "db_automated_backups_replication" {
#   source = "../../modules/db_instance_automated_backups_replication"

#   source_db_instance_arn = module.db.db_instance_arn

#   providers = {
#     aws = aws.region2
#   }
# }

# ################################################################################
# # DMS Module
# ################################################################################

# module "database_migration_service" {
#   source  = "terraform-aws-modules/dms/aws"
#   version = "~> 1.0"

#   # Subnet group
#   repl_subnet_group_name        = "example"
#   repl_subnet_group_description = "DMS Subnet group"
#   repl_subnet_group_subnet_ids  = ["subnet-1fe3d837", "subnet-129d66ab", "subnet-1211eef5"]

#   # Instance
#   repl_instance_allocated_storage            = 64
#   repl_instance_auto_minor_version_upgrade   = true
#   repl_instance_allow_major_version_upgrade  = true
#   repl_instance_apply_immediately            = true
#   repl_instance_engine_version               = "3.4.5"
#   repl_instance_multi_az                     = true
#   repl_instance_preferred_maintenance_window = "sun:10:30-sun:14:30"
#   repl_instance_publicly_accessible          = false
#   repl_instance_class                        = "dms.t3.large"
#   repl_instance_id                           = "example"
#   repl_instance_vpc_security_group_ids       = ["sg-12345678"]

#   endpoints = {
#     source = {
#       database_name               = "example"
#       endpoint_id                 = "example-source"
#       endpoint_type               = "source"
#       engine_name                 = "aurora-postgresql"
#       extra_connection_attributes = "heartbeatFrequency=1;"
#       username                    = "postgresqlUser"
#       password                    = "youShouldPickABetterPassword123!"
#       port                        = 5432
#       server_name                 = "dms-ex-src.cluster-abcdefghijkl.us-east-1.rds.amazonaws.com"
#       ssl_mode                    = "none"
#       tags                        = { EndpointType = "source" }
#     }

#     destination = {
#       database_name = "example"
#       endpoint_id   = "example-destination"
#       endpoint_type = "target"
#       engine_name   = "aurora"
#       username      = "mysqlUser"
#       password      = "passwordsDoNotNeedToMatch789?"
#       port          = 3306
#       server_name   = "dms-ex-dest.cluster-abcdefghijkl.us-east-1.rds.amazonaws.com"
#       ssl_mode      = "none"
#       tags          = { EndpointType = "destination" }
#     }
#   }

#   replication_tasks = {
#     cdc_ex = {
#       replication_task_id       = "example-cdc"
#       migration_type            = "cdc"
#       replication_task_settings = file("task_settings.json")
#       table_mappings            = file("table_mappings.json")
#       source_endpoint_key       = "source"
#       target_endpoint_key       = "destination"
#       tags                      = { Task = "PostgreSQL-to-MySQL" }
#     }
#   }

#   event_subscriptions = {
#     instance = {
#       name                             = "instance-events"
#       enabled                          = true
#       instance_event_subscription_keys = ["example"]
#       source_type                      = "replication-instance"
#       sns_topic_arn                    = "arn:aws:sns:us-east-1:012345678910:example-topic"
#       event_categories                 = [
#         "failure",
#         "creation",
#         "deletion",
#         "maintenance",
#         "failover",
#         "low storage",
#         "configuration change"
#       ]
#     }
#     task = {
#       name                         = "task-events"
#       enabled                      = true
#       task_event_subscription_keys = ["cdc_ex"]
#       source_type                  = "replication-task"
#       sns_topic_arn                = "arn:aws:sns:us-east-1:012345678910:example-topic"
#       event_categories             = [
#         "failure",
#         "state change",
#         "creation",
#         "deletion",
#         "configuration change"
#       ]
#     }
#   }

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }