###########################################
##  Outputs from module resources that need
##  to be exported for use as variables. 
##  Root outputs.tf needs to match 
##  ouput "<name>" from here.
############################################

output "jump-server-1" {
    value = aws_instance.jump-server-1.id
}

output "sql-database-server" {
    value = aws_instance.sql-database-server.id
}

output "ec2instance-private_dns" {
    value = aws_instance.sql-database-server.private_dns
}