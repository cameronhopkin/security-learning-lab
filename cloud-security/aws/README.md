# AWS Security Notes

## Core Security Services

| Service | Purpose |
|---------|---------|
| IAM | Identity and access management |
| GuardDuty | Threat detection |
| Security Hub | Security posture dashboard |
| CloudTrail | API audit logging |
| Config | Configuration compliance |
| KMS | Key management |
| Secrets Manager | Secrets storage |
| WAF | Web application firewall |
| Shield | DDoS protection |

## IAM Best Practices

### Principle of Least Privilege

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

### Never Use Root Account

1. Create IAM users for all access
2. Enable MFA on root account
3. Delete root access keys
4. Use organizations for multi-account

### MFA Everything

```bash
# Require MFA for sensitive operations
aws iam create-virtual-mfa-device \
    --virtual-mfa-device-name user-mfa
```

## S3 Security Checklist

- [ ] Block public access at account level
- [ ] Enable default encryption (SSE-S3 or SSE-KMS)
- [ ] Enable versioning
- [ ] Enable access logging
- [ ] Use bucket policies with least privilege
- [ ] Enable MFA delete for sensitive buckets

### Secure S3 Bucket Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnencryptedUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::my-bucket/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    },
    {
      "Sid": "DenyInsecureTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

## VPC Security

### Security Groups (Stateful)

```terraform
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  # Only allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Internal only
  }

  # Restrict egress
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}
```

### Network ACLs (Stateless)

- Use as additional layer
- Remember both inbound AND outbound rules
- Consider ephemeral port ranges

### VPC Flow Logs

```terraform
resource "aws_flow_log" "main" {
  vpc_id                   = aws_vpc.main.id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.flow_logs.arn
  iam_role_arn             = aws_iam_role.flow_logs.arn
  max_aggregation_interval = 60
}
```

## CloudTrail

Essential for security monitoring and compliance.

```terraform
resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name                = aws_s3_bucket.trail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.trail.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }
  }
}
```

## GuardDuty

Enable in all regions and all accounts:

```bash
# Enable GuardDuty
aws guardduty create-detector --enable

# List findings
aws guardduty list-findings --detector-id <id>
```

## Quick Security Audit Commands

```bash
# Find public S3 buckets
aws s3api list-buckets --query 'Buckets[*].Name' --output text | \
  xargs -I {} aws s3api get-bucket-acl --bucket {} --output json

# List IAM users without MFA
aws iam list-users --query 'Users[*].UserName' --output text | \
  xargs -I {} sh -c 'aws iam list-mfa-devices --user-name {} --query "MFADevices[0].SerialNumber" --output text | grep -q "None" && echo {}'

# Find security groups with 0.0.0.0/0
aws ec2 describe-security-groups \
  --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]].[GroupId,GroupName]' \
  --output table

# Check CloudTrail status
aws cloudtrail describe-trails
```

## References

- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [AWS Well-Architected Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
