#########################################################
## EC2 instance role
#########################################################

resource "aws_iam_role" "role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

#################################################
## IAM Policy for instances
#################################################

resource "aws_iam_policy" "policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "ec2:*"          
        Effect = "Allow"
        Resource = "*"
      },
      {

        Effect = "Allow",
        Action = [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
        Resource = "*"
      },
      {
        Action = [
                "ssm:DescribeDocument",
                "ssm:PutConfigurePackageResult",
                "ssm:ListInstanceAssociations",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceInformation",
                "ssm:GetDocument",
                "ssm:ListDocument",
                "ssm:PutComplianceItems",
                "ssm:DescribeAssociation",
                "ssm:PutInventory",
                "ssm:ListAssociations",
                "ssm:CreateAssociation",
                "ssm:UpdateInstanceAssociationStatus"
            ],
        Effect = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
                "ds:CreateComputer",
                "ds:DescribeDirectories"
            ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
                "s3:GetBucketLocation",
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",              
                "s3:GetEncryptionConfiguration",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads"
            ],
        Resource = "*"
      },
      {
        Action = "elasticloadbalancing:*"
        Effect = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
                "route53:ChangeResourceRecordSets",
                "route53:GetChange",
                "route53:ListHostedZones"
            ],      
        Resource = "*"
      },
      {
        Action = "cloudwatch:*"          
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = "autoscaling:*"
        Effect = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "iam:UploadServerCertificate",
                "iam:CreateServiceLinkedRole"
            ],
        Resource = "*"
      } 
    ]
   }
  )
}

#########################################################
## EC2 session manager Role Policy attachment
#########################################################
resource "aws_iam_role_policy_attachment" "attach_ssm_role" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

#########################################################
## EC2 instance profile role
#########################################################

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "${var.region}-${var.namespace}--ec2-instance-profile"
  role = aws_iam_role.role.name
}

#########################################################
##  IAM Role for sftp
#########################################################

resource "aws_iam_role" "sftp-role" {

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "transfer.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
  description           = "Allow AWS Transfer to call AWS services on your behalf."
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "${var.region}-sftp-transfer-role"
  path                  = "/"
}

#################################################
## IAM Policy for sftp
#################################################

resource "aws_iam_policy" "sftp-policy" {
  name = "${var.region}-sftp-policy"
  # path = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = "s3:ListBucket"
          Effect = "Allow"
          Resource = "${var.sftp-bucket}"
          Sid = "AllowListingOfUserFolder"
        },
        {
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:DeleteObjectVersion",
            "s3:GetBucketLocation",
            "s3:GetObjectVersion",
            "s3:GetObjectACL",
            "s3:PutObjectACL",
          ]
          Effect   = "Allow"
          Resource = "${var.sftp-bucket}/*"
          Sid      = "HomeDirObjectAccess"
        },
      ]
      Version = "2012-10-17"
    }
  )
}


#########################################################
## IAM Attach Policy sftp
#########################################################

resource "aws_iam_policy_attachment" "sftp-policy-attach" {
  name       = "${var.region}-${var.namespace}-sftp policy attachment"
  roles      = [aws_iam_role.sftp-role.name]
  policy_arn = aws_iam_policy.sftp-policy.arn
}

#########################################################
##  IAM Role for rds-sftp and trust
#########################################################

resource "aws_iam_role" "rds-sftp-role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Sid = ""
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
              "transfer.amazonaws.com",
              "rds.amazonaws.com"
            ]
          }
        }
      ]
      Version = "2012-10-17"
    }
  )
  description           = "Allow AWS Transfer to call AWS services on your behalf."
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "${var.region}-rds-sftp-role"
  path                  = "/"
}

#################################################
## IAM Policy for rds-sftp
#################################################

resource "aws_iam_policy" "rds-sftp-policy" {
  name = "${var.region}-rds-sftp-policy"
  path = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:ListBucket",
          ]
          Effect = "Allow"
          Resource = "${var.sftp-bucket}"
          Sid = "AllowListingOfUserFolder"
        },
        {
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:DeleteObjectVersion",
            "s3:GetBucketLocation",
            "s3:GetObjectVersion",
            "s3:GetObjectACL",
            "s3:PutObjectACL",
          ]
          Effect   = "Allow"
          Resource = "${var.sftp-bucket}/*"
          Sid      = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
}

#########################################################
## IAM Attach Policy rds-sftp
#########################################################

resource "aws_iam_policy_attachment" "rds-sftp-policy-attach" {
  name       = "${var.region}-${var.namespace}-rds-sftp policy attachment"
  roles      = [aws_iam_role.rds-sftp-role.name]
  policy_arn = aws_iam_policy.rds-sftp-policy.arn
}



#########################################################
##  IAM Role for rds-ad and trust
#########################################################

resource "aws_iam_role" "rds-ad-role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Sid = ""
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
              "ds.amazonaws.com",
              "rds.amazonaws.com"
            ]
          }
        }
      ]
      Version = "2012-10-17"
    }
  )
  description           = "Allow AWS Transfer to call AWS services on your behalf."
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "${var.region}-rds-ad-role"
  path                  = "/"
}

#################################################
## IAM Policy for rds-ad
#################################################

resource "aws_iam_policy" "rds-ad-policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "ec2:*"          
        Effect = "Allow"
        Resource = "*"
      },
      {

        Effect = "Allow",
        Action = [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
        Resource = "*"
      },
      {
        Action = [
                "ssm:DescribeDocument",
                "ssm:PutConfigurePackageResult",
                "ssm:ListInstanceAssociations",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceInformation",
                "ssm:GetDocument",
                "ssm:ListDocument",
                "ssm:PutComplianceItems",
                "ssm:DescribeAssociation",
                "ssm:PutInventory",
                "ssm:ListAssociations",
                "ssm:CreateAssociation",
                "ssm:UpdateInstanceAssociationStatus"
            ],
        Effect = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
                "ds:CreateComputer",
                "ds:DescribeDirectories"
            ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
                "s3:GetBucketLocation",
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",              
                "s3:GetEncryptionConfiguration",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads"
            ],
        Resource = "*"
      },
      {
        Action = "elasticloadbalancing:*"
        Effect = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
                "route53:ChangeResourceRecordSets",
                "route53:GetChange",
                "route53:ListHostedZones"
            ],      
        Resource = "*"
      },
      {
        Action = "cloudwatch:*"          
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = "autoscaling:*"
        Effect = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "iam:UploadServerCertificate",
                "iam:CreateServiceLinkedRole"
            ],
        Resource = "*"
      } 
    ]
   }
  )
}


#########################################################
## IAM Attach Policy rds-ad
#########################################################

resource "aws_iam_policy_attachment" "rds-ad-policy-attach" {
  name       = "${var.region}-${var.namespace}-rds-ad policy attachment"
  roles      = [aws_iam_role.rds-ad-role.name]
  policy_arn = aws_iam_policy.rds-ad-policy.arn
}

########################################################################################################################
## Database Migration Service requires the below IAM Roles to be created before
## replication instances can be created. See the DMS Documentation for
## additional information: https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.html#CHAP_Security.APIRole
##  * dms-vpc-role
##  * dms-cloudwatch-logs-role
##  * dms-access-for-endpoint
########################################################################################################################

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms-access-for-endpoint.name
}


resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
}

resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}

resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}