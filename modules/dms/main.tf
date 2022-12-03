# ################################################################################
# # DMS Module
# ################################################################################
resource "aws_dms_replication_subnet_group" "test" {
  replication_subnet_group_description = "Replication subnet group"
  replication_subnet_group_id          = "test-dms-replication-subnet-group-tf"
  subnet_ids = ["subnet-0cdc3f3354a897c85", "subnet-05ab00755f1543bb0", "subnet-0976a8c9e058a2b0a"]
}

resource "aws_dms_replication_instance" "replication_instance" {
  allocated_storage           = 50
  multi_az                    = false
  replication_instance_class  = "dms.c5.xlarge"
  replication_instance_id     = "test-dms-replication-instance-tf"
  replication_subnet_group_id = aws_dms_replication_subnet_group.test.id
  tags = {
    Name = "${var.namespace}-DMSReplicationInstance"
  }

  # depends_on = [
  #   aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
  #   aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole,
  #   aws_db_instance.default,
  #   aws_db_subnet_group.default
  # ]
}


resource "aws_dms_endpoint" "target_endpoint" {
  database_name = "targetdb"
  endpoint_id   = "sqlserver-target"
  endpoint_type = "target"
  engine_name   = "sqlserver"
  password      = "Password1"
  username      = "awssct"
  port          = 1433
  server_name   = var.target-endpoint
  ssl_mode      = "none"

  tags = {
    Name = "sqlserver-target"
  }
  depends_on = [
    aws_dms_replication_instance.replication_instance
  ]
}


resource "aws_dms_endpoint" "source_endpoint" {
  database_name = "dms_sample"
  endpoint_id   = "sqlserver-source"
  endpoint_type = "source"
  engine_name   = "sqlserver"
  password      = "Password1"
  username      = "awssct"
  port          = 1433
  server_name   = var.ec2instance-private_dns
  ssl_mode      = "none"

  tags = {
    Name = "sqlserver-source"
  }
  depends_on = [
    aws_dms_replication_instance.replication_instance
  ]
}

resource "aws_dms_replication_task" "replication_task" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.replication_instance.replication_instance_arn
  replication_task_id       = "test-dms-replication-task-tf"
  replication_task_settings = "{   \"TargetMetadata\": {     \"TargetSchema\": \"\",     \"SupportLobs\": true,     \"FullLobMode\": false,     \"LobChunkSize\": 64,     \"LimitedSizeLobMode\": true,     \"LobMaxSize\": 32,     \"InlineLobMaxSize\": 0,     \"LoadMaxFileSize\": 0,     \"ParallelLoadThreads\": 0,     \"ParallelLoadBufferSize\":0,     \"ParallelLoadQueuesPerThread\": 1,     \"ParallelApplyThreads\": 0,     \"ParallelApplyBufferSize\": 100,     \"ParallelApplyQueuesPerThread\": 1,         \"BatchApplyEnabled\": false,     \"TaskRecoveryTableEnabled\": false   },   \"FullLoadSettings\": {     \"TargetTablePrepMode\": \"DO_NOTHING\",     \"CreatePkAfterFullLoad\": false,     \"StopTaskCachedChangesApplied\": false,     \"StopTaskCachedChangesNotApplied\": false,     \"MaxFullLoadSubTasks\": 8,     \"TransactionConsistencyTimeout\": 600,     \"CommitRate\": 10000   },   \"Logging\": {     \"EnableLogging\": false   },   \"ValidationSettings\": {     \"EnableValidation\": true,     \"ValidationMode\": \"ROW_LEVEL\",     \"ThreadCount\": 5,     \"PartitionSize\": 10000,     \"FailureMaxCount\": 1000,     \"RecordFailureDelayInMinutes\": 5,     \"RecordSuspendDelayInMinutes\": 30,     \"MaxKeyColumnSize\": 8096,     \"TableFailureMaxCount\": 10000,     \"ValidationOnly\": false,     \"HandleCollationDiff\": false,     \"RecordFailureDelayLimitInMinutes\": 1,     \"SkipLobColumns\": false,     \"ValidationPartialLobSize\": 0,     \"ValidationQueryCdcDelaySeconds\": 0   } }"
  source_endpoint_arn       = aws_dms_endpoint.source_endpoint.endpoint_arn
  table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"

  tags = {
    Name = "test"
  }

  target_endpoint_arn = aws_dms_endpoint.target_endpoint.endpoint_arn

  depends_on = [
    aws_dms_replication_instance.replication_instance,
    aws_dms_endpoint.source_endpoint,
    aws_dms_endpoint.target_endpoint
  ]
}



# module "database_migration_service" {
#   source  = "terraform-aws-modules/dms/aws"
#   version = "~> 1.0"

#   # Subnet group
#   repl_subnet_group_name        = "example"
#   repl_subnet_group_description = "DMS Subnet group"
#   repl_subnet_group_subnet_ids  = aws_dms_replication_subnet_group.test.subnet_ids

#   # Instance
#   repl_instance_allocated_storage            = 64
#   # repl_instance_auto_minor_version_upgrade   = true
#   # repl_instance_allow_major_version_upgrade  = true
#   repl_instance_apply_immediately            = true
#   repl_instance_engine_version               = "3.4.7"
#   repl_instance_multi_az                     = false
#   repl_instance_preferred_maintenance_window = "sun:10:30-sun:14:30"
#   repl_instance_publicly_accessible          = false
#   repl_instance_class                        = "dms.c5.xlarge"
#   repl_instance_id                           = "DMSReplication"
#   repl_instance_vpc_security_group_ids       = [var.database-sg]

#   endpoints = {
#     source = {
#       database_name               = "dms_sample"
#       endpoint_id                 = "sqlserver-source"
#       endpoint_type               = "source"
#       engine_name                 = "sqlserver"
#       username                    = "awssct"
#       password                    = "Password1"
#       port                        = 1433
#       server_name                 = var.ec2instance-private_dns
#       ssl_mode                    = "none"
#       tags                        = { EndpointType = "source" }
#     }

#     destination = {
#       database_name = "dms-recovery"
#       endpoint_id   = "sqlserver-target"
#       endpoint_type = "target"
#       engine_name   = "sqlserver"
#       username      = "dbmaster"
#       password      = "dbmaster123"
#       port          =  1433
#       server_name   = var.target-endpoint
#       ssl_mode      = "none"
#       tags          = { EndpointType = "destination" }
#     }
#   }

#   replication_tasks = {
#     cdc_ex = {
#       replication_task_id       = "SampleMigrationTask"
#       migration_type            = "full-load-and-cdc"
#       cdc_stop_mode             = "Don’t use custom CDC stop mode"
#       replication_task_settings = "{   \"TargetMetadata\": {     \"TargetSchema\": \"\",     \"SupportLobs\": true,     \"FullLobMode\": false,     \"LobChunkSize\": 64,     \"LimitedSizeLobMode\": true,     \"LobMaxSize\": 32,     \"InlineLobMaxSize\": 0,     \"LoadMaxFileSize\": 0,     \"ParallelLoadThreads\": 0,     \"ParallelLoadBufferSize\":0,     \"ParallelLoadQueuesPerThread\": 1,     \"ParallelApplyThreads\": 0,     \"ParallelApplyBufferSize\": 100,     \"ParallelApplyQueuesPerThread\": 1,         \"BatchApplyEnabled\": false,     \"TaskRecoveryTableEnabled\": false   },   \"FullLoadSettings\": {     \"TargetTablePrepMode\": \"DO_NOTHING\",     \"CreatePkAfterFullLoad\": false,     \"StopTaskCachedChangesApplied\": false,     \"StopTaskCachedChangesNotApplied\": false,     \"MaxFullLoadSubTasks\": 8,     \"TransactionConsistencyTimeout\": 600,     \"CommitRate\": 10000   },   \"Logging\": {     \"EnableLogging\": false   },   \"ValidationSettings\": {     \"EnableValidation\": true,     \"ValidationMode\": \"ROW_LEVEL\",     \"ThreadCount\": 5,     \"PartitionSize\": 10000,     \"FailureMaxCount\": 1000,     \"RecordFailureDelayInMinutes\": 5,     \"RecordSuspendDelayInMinutes\": 30,     \"MaxKeyColumnSize\": 8096,     \"TableFailureMaxCount\": 10000,     \"ValidationOnly\": false,     \"HandleCollationDiff\": false,     \"RecordFailureDelayLimitInMinutes\": 1,     \"SkipLobColumns\": false,     \"ValidationPartialLobSize\": 0,     \"ValidationQueryCdcDelaySeconds\": 0   } }"
#       table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"dbo\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
#       source_endpoint_key       = "source"
#       target_endpoint_key       = "destination"
#       tags                      = { Task = "mssql to rds-mssql" }
#     }
#   }

#   tags = {
#     Name = "${var.region}-dms"
#     Project = "${var.namespace}"
#     environment = "${terraform.workspace}"
#   }
# }