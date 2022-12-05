#########################################################
## Creates password for Secret Manager
#########################################################

## PASSWORD FOR DIRECTORY SERVICE ADMIN USER

resource "aws_secretsmanager_secret" "ds_admin" {
  name = "ds_admin"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ds_admin" {
  secret_id     = aws_secretsmanager_secret.ds_admin.id
  secret_string = "Password1"
}

## PASSWORD FOR USER awssct USED FOR RDS INSTANCES AND DMS TARGET/SOURCE DB'S

resource "aws_secretsmanager_secret" "awssct" {
  name = "awssct"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "awssct" {
  secret_id     = aws_secretsmanager_secret.ds_admin.id
  secret_string = "Password1"
}
