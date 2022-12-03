output "rds-sftp-role" {
    value = aws_iam_role.rds-sftp-role.name
}

output "rds-sftp-policy" {
    value = aws_iam_policy.rds-sftp-policy.arn
}

output "ec2-instance-profile" {
    value = aws_iam_instance_profile.ec2-profile.name
}

output "sftp-role" {
    value = aws_iam_role.sftp-role.name
}

output "sftp-policy" {
    value = aws_iam_policy.sftp-policy.name
}

output "rds-ad-role" {
    value = aws_iam_role.rds-ad-role.name
}

output "rds-ad-policy" {
    value = aws_iam_policy.rds-ad-policy.arn
}
