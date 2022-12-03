############################################
##  Outputs from module resources that need
##  to be exported for use as variables. 
##  Root outputs.tf needs to match 
##  ouput "<name>" from here.
############################################

output "sftp-bucket" {
  value = aws_s3_bucket.sftp-bucket.arn
}