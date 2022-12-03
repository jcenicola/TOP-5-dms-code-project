#########################################################
## Deploy jump-box Instances 
#########################################################

resource "aws_instance" "jump-server-1" {
  ami                    = var.win-server-2019
  instance_type          = var.jump_instance_type
  key_name               = var.key_pair
  subnet_id              = var.public-subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [var.public-sg]
  iam_instance_profile = var.ec2-instance-profile
  
    tags = {
    Name = "${terraform.workspace}-${var.region}-jump-server-1"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
    }
}

#########################################################
## Deploy on-prim simulated MS SQL database  Instances
#########################################################

resource "aws_instance" "sql-database-server" {
  
  ami                    = var.sql-database-server
  instance_type          = var.win_instance_type
  key_name               = var.key_pair
  subnet_id              = var.app-subnets[0]
  associate_public_ip_address = false
  vpc_security_group_ids = [var.app-sg]
  iam_instance_profile = var.ec2-instance-profile
  root_block_device {
    volume_size = var.volume_size
  }
  
    tags = {
    Name = "${terraform.workspace}-${var.region}-sql-database-server"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
    }
}