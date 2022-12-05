############################################
##  Outputs from module resources that need
##  to be exported for use as variables. 
##  Root outputs.tf needs to match 
##  ouput "<name>" from here.
############################################

output "ds_admin" {
    value = aws_secretsmanager_secret_version.ds_admin.secret_string
}

output "awssct" {
    value = aws_secretsmanager_secret_version.awssct.secret_string
}
