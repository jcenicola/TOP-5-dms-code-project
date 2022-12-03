############################################
##  Outputs from module resources that need
##  to be exported for use as variables. 
##  Root outputs.tf needs to match 
##  ouput "<name>" from here.
############################################

output "ds-id" {
    value = aws_directory_service_directory.ds.id
}

output "ds-dns" {
    value = aws_directory_service_directory.ds.dns_ip_addresses
}

output "ds-name" {
    value = aws_directory_service_directory.ds.name
}

output "admin" {
    value = aws_secretsmanager_secret_version.admin.secret_string
}


