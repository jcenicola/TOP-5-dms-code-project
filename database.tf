resource "aws_security_group" "rds_security_group" {
  name        = "rds_security_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.dms_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dms_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.testname}-RDSSecurityGroup"
  }
}


resource "aws_db_instance" "default" {
  allocated_storage       = 100
  license_model           = "license-included"
  engine                  = "sqlserver-se"
  engine_version          = "15.00.4073.23.v1"
  instance_class          = "db.r5.xlarge"
  iops                    = "2000"
  username                = "awssct"
  password                = "Password1"
  backup_retention_period = 0
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.rds_security_group.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name
  depends_on = [
    aws_security_group.rds_security_group
  ]
}