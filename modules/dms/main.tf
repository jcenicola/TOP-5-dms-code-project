#################################################################################
## DMS Module
#################################################################################

########################################
## Creating replication subnet group
########################################
resource "aws_dms_replication_subnet_group" "test" {
  replication_subnet_group_description = "Replication subnet group"
  replication_subnet_group_id          = "test-dms-replication-subnet-group-tf"
  subnet_ids = var.database-subnets
}

#########################################
## Creating replication Instance
#########################################
resource "aws_dms_replication_instance" "replication_instance" {
  allocated_storage           = var.dms_allocated_storage
  multi_az                    = var.dms_multi_az
  replication_instance_class  = var.replication_instance_class
  replication_instance_id     = "test-dms-replication-instance-tf"
  replication_subnet_group_id = aws_dms_replication_subnet_group.test.id
  tags = {
    Name = "${var.namespace}-DMSReplicationInstance"
  }
}

#########################################
## Creating Target Endpoint
#########################################

resource "aws_dms_endpoint" "target_endpoint" {
  database_name = var.target_database_name
  endpoint_id   = "sqlserver-target"
  endpoint_type = "target"
  engine_name   = "sqlserver"
  password      = var.awssct
  username      = var.target_username
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

#########################################
## Creating Source Endpoint
#########################################

resource "aws_dms_endpoint" "source_endpoint" {
  database_name = var.source_database_name
  endpoint_id   = "sqlserver-source"
  endpoint_type = "source"
  engine_name   = "sqlserver"
  password      = var.awssct
  username      = var.source_username
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

#########################################
## Creating Replication Task
#########################################

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