#!/bin/bash
# AWS Security Quick Audit Script
# Usage: ./aws-security-audit.sh [profile]

set -e

PROFILE="${1:-default}"
AWS_OPTS="--profile $PROFILE --output json"

echo "=========================================="
echo "AWS Security Audit - Profile: $PROFILE"
echo "=========================================="
echo ""

# Check IAM Users without MFA
echo "=== IAM Users Without MFA ==="
aws iam list-users $AWS_OPTS --query 'Users[*].UserName' --output text | while read user; do
    mfa=$(aws iam list-mfa-devices $AWS_OPTS --user-name "$user" --query 'MFADevices[0].SerialNumber' --output text 2>/dev/null)
    if [ "$mfa" == "None" ] || [ -z "$mfa" ]; then
        echo "  ⚠️  $user - NO MFA"
    fi
done
echo ""

# Check for root access keys
echo "=== Root Account Access Keys ==="
root_keys=$(aws iam get-account-summary $AWS_OPTS --query 'SummaryMap.AccountAccessKeysPresent')
if [ "$root_keys" -gt 0 ]; then
    echo "  ❌ Root account has access keys - REMOVE THEM!"
else
    echo "  ✅ No root access keys"
fi
echo ""

# Check Security Groups with 0.0.0.0/0
echo "=== Security Groups with Open Access (0.0.0.0/0) ==="
aws ec2 describe-security-groups $AWS_OPTS \
    --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]].[GroupId,GroupName,Description]' \
    --output table
echo ""

# Check for public S3 buckets
echo "=== S3 Bucket Public Access Status ==="
aws s3api list-buckets $AWS_OPTS --query 'Buckets[*].Name' --output text | while read bucket; do
    # Check public access block
    pab=$(aws s3api get-public-access-block $AWS_OPTS --bucket "$bucket" 2>/dev/null || echo "NOT_CONFIGURED")
    if [[ "$pab" == "NOT_CONFIGURED" ]]; then
        echo "  ⚠️  $bucket - Public Access Block NOT configured"
    fi
done
echo ""

# Check CloudTrail status
echo "=== CloudTrail Status ==="
trails=$(aws cloudtrail describe-trails $AWS_OPTS --query 'trailList[*].[Name,IsMultiRegionTrail,LogFileValidationEnabled]' --output table)
echo "$trails"
echo ""

# Check GuardDuty status
echo "=== GuardDuty Status ==="
detectors=$(aws guardduty list-detectors $AWS_OPTS --query 'DetectorIds' --output text)
if [ -z "$detectors" ]; then
    echo "  ❌ GuardDuty NOT enabled"
else
    echo "  ✅ GuardDuty enabled - Detector IDs: $detectors"
fi
echo ""

# Check for unencrypted EBS volumes
echo "=== Unencrypted EBS Volumes ==="
aws ec2 describe-volumes $AWS_OPTS \
    --query 'Volumes[?Encrypted==`false`].[VolumeId,Size,State]' \
    --output table
echo ""

# Check RDS encryption
echo "=== RDS Instances Encryption Status ==="
aws rds describe-db-instances $AWS_OPTS \
    --query 'DBInstances[*].[DBInstanceIdentifier,StorageEncrypted]' \
    --output table
echo ""

# Password policy
echo "=== IAM Password Policy ==="
aws iam get-account-password-policy $AWS_OPTS 2>/dev/null || echo "  ⚠️  No password policy configured!"
echo ""

echo "=========================================="
echo "Audit Complete"
echo "=========================================="
