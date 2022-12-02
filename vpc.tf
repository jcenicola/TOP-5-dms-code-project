resource "aws_vpc" "dms_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.testname}"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.dms_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.dms_vpc.cidr_block, 3, 0)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.testname}-subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.dms_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.dms_vpc.cidr_block, 3, 1)
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.testname}-subnet2"
  }
}



resource "aws_subnet" "subnet3" {
  vpc_id            = aws_vpc.dms_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.dms_vpc.cidr_block, 3, 2)
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "${var.testname}-subnet3"
  }
}


resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dms_vpc.id

  tags = {
    Name = "${var.testname}-InternetGateway"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.dms_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.testname}-RouteTable"
  }
}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.this.id
}


resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.this.id
}


resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.this.id
}

