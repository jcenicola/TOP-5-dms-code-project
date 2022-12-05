###########################################
## Building the VPC
###########################################

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.namespace}-vpc"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
    }
}

###########################################
## Creating the Subnets (Public & Private)
###########################################

resource "aws_subnet" "public-subnets" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.azs)
  cidr_block        = element(var.public-subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.region}-public-subnet-${count.index + 1}"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "app-subnets" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.azs)
  cidr_block        = element(var.app-subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.region}-app-subnet-${count.index + 1}"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "database-subnets" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.azs)
  cidr_block        = element(var.database-subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.region}-database-subnet-${count.index + 1}"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
  }
}

###########################################
## Creating the Internet Gateway
###########################################

resource "aws_internet_gateway" "igw" {
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "-${var.region}-igw"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
  }
}

###########################################
## Creating the Route Tables
###########################################

resource "aws_route_table" "public-rt" {
  vpc_id            = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.region}-public-rt"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
  }
}
resource "aws_route_table" "app-rt" {
  vpc_id            = aws_vpc.vpc.id
  count  = length(var.app-subnets)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway[count.index].id
  }
 
  tags = {
    Name = "${var.region}-app-rt-${count.index + 1}"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
  }
}
resource "aws_route_table" "database-rt" {
  vpc_id            = aws_vpc.vpc.id
  count  = length(var.database-subnets)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway[count.index].id
  }
  tags = {
    Name = "${var.region}-database-rt-${count.index + 1}"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
  }
}

###################################################
## Creating subnet association for the route table
###################################################

resource "aws_route_table_association" "public-subnet-association" {
  count          = length(var.public-subnets)
  subnet_id      = element(aws_subnet.public-subnets.*.id, count.index)
  route_table_id = aws_route_table.public-rt.id
}
resource "aws_route_table_association" "app-subnet-association" {
  count          = length(var.app-subnets)
  subnet_id      = element(aws_subnet.app-subnets.*.id, count.index)
  route_table_id = aws_route_table.app-rt[count.index].id
}
resource "aws_route_table_association" "database-subnet-association" {
  count          = length(var.database-subnets)
  subnet_id      = element(aws_subnet.database-subnets.*.id, count.index)
  route_table_id = aws_route_table.database-rt[count.index].id
}

###########################################
###  Alocating EIP's for Nat-GW's
###########################################

resource "aws_eip" "nat-eip" {
  count = 3
  vpc = true
}

###########################################
## Creating the Nat Gateways
###########################################

resource "aws_nat_gateway" "nat-gateway" {
  count         = length(var.azs)
  allocation_id = element(aws_eip.nat-eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public-subnets.*.id, count.index)

  tags = {
    Name = "${var.region}-nat-gw-${count.index + 1}"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
    }
  }

  ###########################################
## Creating a vpc endpoint
###########################################

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids = [var.database-sg]

  private_dns_enabled = true

  tags = {
    Name = "${var.region}-vpc-endpoint"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
  }
}

#########################################################
## Create Security Groups
#########################################################

###########################################
## public security group
###########################################

resource "aws_security_group" "public-sg" {
  name        = "${terraform.workspace}-${var.region}-public-sg"
  description = "Allow public access to jump"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow rdp access"
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
    Name = "${terraform.workspace}-${var.region}-public-sg"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
  }
}

###########################################
## app security group - private
###########################################

resource "aws_security_group" "app-sg" {
  name        = "${terraform.workspace}-${var.region}-app-sg"
  description = "Allow access from jump/alb"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow rdp from jump server"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    security_groups   = [aws_security_group.public-sg.id]
  }
  ingress {
    description = "Allows Amazon RDS Aurora (MySQL) Access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allows SQL Server Access"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allows SQL Server Access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 1521
    to_port     = 1521
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
    Name = "${terraform.workspace}-${var.region}-app-sg"
    Project = "${var.namespace}"
    environment = "${terraform.workspace}"
  }
}

###########################################
## database security group - private
###########################################

resource "aws_security_group" "database-sg" {
  name        = "${terraform.workspace}-${var.region}-database_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allows SQL Server Access"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${terraform.workspace}-${var.region}-database-sg"
    Project = "${var.namespace}"

    environment = "${terraform.workspace}"
  }
}
