#########################################################
## Deploys - Directory service
#########################################################

resource "aws_directory_service_directory" "ds" {
  name      = var.ds_domain_name
  password  = var.ds_admin
  edition   = var.ds_edition
  type      = var.ds_type

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
