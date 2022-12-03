##################################################
## S3 Bucket Creation for sftp (family-transfer)
##################################################

resource "aws_s3_bucket" "sftp-bucket" {
  bucket = "${var.region}-sftp-bucket-${var.namespace}"
  tags = {
    Name = "${var.region}-sftp-bucket"
    Project = "${var.namespace}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_acl" "sftp" {
  bucket = aws_s3_bucket.sftp-bucket.id
  acl    = "private"
}

#########################################################
## Enable AWS Transfer Family (SFTP Service Managed)
#########################################################

resource "aws_transfer_server" "service_managed" {
  endpoint_type          = "PUBLIC"
  identity_provider_type = "SERVICE_MANAGED"
  tags = {
    Name = "${var.region}-sftp-service"
    Project = "${var.namespace}"
    environment = var.environment
    }

}
