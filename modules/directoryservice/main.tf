#########################################################
## Retrieve's the password from Parameter Store
#########################################################

# data "aws_ssm_parameter" "ds-dev" {
#   name = "ds-dev"
# }
resource "aws_secretsmanager_secret" "admin" {
  name = "admin"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "admin" {
  secret_id     = aws_secretsmanager_secret.admin.id
  secret_string = "Password1"
}

#########################################################
## Deploys MicrosoftAD - Directory service
#########################################################

resource "aws_directory_service_directory" "ds" {
  name     = "team1.com"
  password = aws_secretsmanager_secret_version.admin.secret_string
  edition = "Standard"
  type = "MicrosoftAD"

lifecycle {
    ignore_changes = [
      password,
    ]
  }
  vpc_settings {
    vpc_id = var.vpc_id
    subnet_ids = [var.app-subnets[0], var.app-subnets[1]]
  }
  tags = {
    Name = "${terraform.workspace}-${var.namespace}-directory-service"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
  }
}
