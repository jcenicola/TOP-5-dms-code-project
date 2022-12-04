############################################
##  Outputs from module resources that need
##  to be exported for use as variables. 
##  Root outputs.tf needs to match 
##  ouput "<name>" from here.
############################################

output "target-endpoint" {
    value = aws_db_instance.default.address
}

# output "rds-instance-id" {
#     value = module.rds.db_instance_id
# }
