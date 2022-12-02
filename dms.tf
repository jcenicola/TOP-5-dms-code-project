resource "aws_dms_replication_subnet_group" "test" {
  replication_subnet_group_description = "Test replication subnet group"
  replication_subnet_group_id          = "test-dms-replication-subnet-group-tf"

  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]
}




resource "aws_dms_replication_instance" "replication_instance" {
  allocated_storage           = 50
  multi_az                    = false
  replication_instance_class  = "dms.c5.xlarge"
  replication_instance_id     = "test-dms-replication-instance-tf"
  replication_subnet_group_id = aws_dms_replication_subnet_group.test.id
  tags = {
    Name = "${var.testname}-DMSReplicationInstance"
  }

  depends_on = [
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole,
    aws_db_instance.default,
    aws_db_subnet_group.default
  ]
}


resource "aws_dms_endpoint" "target_endpoint" {
  database_name = "targetdb"
  endpoint_id   = "target-dms-endpoint-tf"
  endpoint_type = "target"
  engine_name   = "sqlserver"
  password      = "Password1"
  username      = "awssct"
  port          = 1433
  server_name   = aws_db_instance.default.address
  ssl_mode      = "none"

  tags = {
    Name = "target-dms-endpoint-tf"
  }
  depends_on = [
    aws_dms_replication_instance.replication_instance
  ]
}


resource "aws_dms_endpoint" "source_endpoint" {
  database_name = "dms_sample"
  endpoint_id   = "source-dms-endpoint-tf"
  endpoint_type = "source"
  engine_name   = "sqlserver"
  password      = "Password1"
  username      = "awssct"
  port          = 1433
  server_name   = "ec2-50-19-61-64.compute-1.amazonaws.com"
  ssl_mode      = "none"

  tags = {
    Name = "source-dms-endpoint-tf"
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
