# AWS IAM Policy Patterns

## Policy Structure

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DescriptiveName",
      "Effect": "Allow|Deny",
      "Action": ["service:Action"],
      "Resource": ["arn:aws:..."],
      "Condition": {}
    }
  ]
}
```

## Common Patterns

### Read-Only S3 Access

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3ReadOnly",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ]
    }
  ]
}
```

### EC2 Instance Connect

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2InstanceConnect",
      "Effect": "Allow",
      "Action": "ec2-instance-connect:SendSSHPublicKey",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringEquals": {
          "ec2:osuser": "ec2-user"
        }
      }
    }
  ]
}
```

### Require MFA

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyWithoutMFA",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:ListMFADevices",
        "iam:ListUsers",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice"
      ],
      "Resource": "*",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
```

### Restrict by IP

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyOutsideNetwork",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "NotIpAddress": {
          "aws:SourceIp": [
            "192.0.2.0/24",
            "203.0.113.0/24"
          ]
        }
      }
    }
  ]
}
```

### Restrict by Region

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyNonUsRegions",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "us-east-1",
            "us-west-2"
          ]
        }
      }
    }
  ]
}
```

### Time-Based Access

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BusinessHoursOnly",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "DateGreaterThan": {
          "aws:CurrentTime": "2025-01-01T17:00:00Z"
        },
        "DateLessThan": {
          "aws:CurrentTime": "2025-01-02T09:00:00Z"
        }
      }
    }
  ]
}
```

### Resource Tagging Requirement

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RequireTagOnCreate",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateVolume"
      ],
      "Resource": "*",
      "Condition": {
        "Null": {
          "aws:RequestTag/Environment": "true"
        }
      }
    }
  ]
}
```

## Service Control Policies (SCPs)

### Prevent Leaving Organization

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PreventLeaving",
      "Effect": "Deny",
      "Action": "organizations:LeaveOrganization",
      "Resource": "*"
    }
  ]
}
```

### Require Encryption

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RequireS3Encryption",
      "Effect": "Deny",
      "Action": "s3:PutObject",
      "Resource": "*",
      "Condition": {
        "Null": {
          "s3:x-amz-server-side-encryption": "true"
        }
      }
    },
    {
      "Sid": "RequireEBSEncryption",
      "Effect": "Deny",
      "Action": "ec2:CreateVolume",
      "Resource": "*",
      "Condition": {
        "Bool": {
          "ec2:Encrypted": "false"
        }
      }
    }
  ]
}
```

## Permission Boundaries

Limit maximum permissions for IAM entities:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowedServices",
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "dynamodb:*",
        "lambda:*",
        "logs:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyIAMChanges",
      "Effect": "Deny",
      "Action": [
        "iam:*",
        "organizations:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Policy Evaluation Logic

1. **Explicit Deny** - Always wins
2. **Explicit Allow** - If no deny
3. **Implicit Deny** - Default

Order of evaluation:
1. Organization SCPs
2. Resource-based policies
3. Permission boundaries
4. Session policies
5. Identity-based policies

## Best Practices

1. Start with AWS managed policies, then customize
2. Use policy variables: `${aws:username}`
3. Test with IAM Policy Simulator
4. Use Access Analyzer for unused permissions
5. Regular permission audits
