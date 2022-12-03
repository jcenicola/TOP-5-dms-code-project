############################################
##  Outputs from module resources that need
##  to be exported for use as variables. 
##  Root outputs.tf needs to match 
##  ouput "<name>" from here.
############################################

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public-subnets" {
  value = aws_subnet.public-subnets[*].id
}

output "app-subnets" {
  value = aws_subnet.app-subnets[*].id
}

output "database-subnets" {
  value = aws_subnet.database-subnets[*].id
}

output "public-sg" {
    value = aws_security_group.public-sg.id
}

output "app-sg" {
    value = aws_security_group.app-sg.id
}

output "database-sg" {
    value = aws_security_group.database-sg.id
}

output "vpc-endpoint" {
    value = aws_vpc_endpoint.ec2.dns_entry
}