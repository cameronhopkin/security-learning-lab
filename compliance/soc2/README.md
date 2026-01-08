# SOC 2 Compliance Notes

## Overview

SOC 2 (Service Organization Control 2) is an auditing framework for service providers storing customer data in the cloud.

## Trust Service Criteria (TSC)

### 1. Security (Common Criteria)
Required for all SOC 2 reports.

| CC | Category | Description |
|----|----------|-------------|
| CC1 | Control Environment | Tone at the top, governance |
| CC2 | Communication | Internal/external communication |
| CC3 | Risk Assessment | Risk identification and management |
| CC4 | Monitoring | Control monitoring activities |
| CC5 | Control Activities | Policies and procedures |
| CC6 | Logical Access | Access controls, authentication |
| CC7 | System Operations | Change management, incidents |
| CC8 | Change Management | System changes |
| CC9 | Risk Mitigation | Business continuity |

### 2. Availability
System is available for operation as committed.

Key controls:
- Uptime monitoring
- Disaster recovery
- Capacity planning
- Incident response

### 3. Processing Integrity
System processing is complete, valid, accurate, timely.

Key controls:
- Input validation
- Error handling
- Processing verification
- Output reconciliation

### 4. Confidentiality
Confidential information is protected.

Key controls:
- Data classification
- Encryption
- Access restrictions
- Secure disposal

### 5. Privacy
Personal information handled per privacy notice.

Key controls:
- Privacy notice
- Consent management
- Data minimization
- Subject rights

## SOC 2 Type I vs Type II

| Type | Description | Period |
|------|-------------|--------|
| Type I | Design of controls | Point in time |
| Type II | Operating effectiveness | 6-12 months |

## Common Control Examples

### Access Control (CC6)

```
Control: Access to systems requires unique user IDs and strong passwords.

Test: Sampled 25 user accounts:
- All had unique IDs ✓
- Password policy enforced ✓
- MFA enabled ✓
```

### Change Management (CC8)

```
Control: Changes to production systems require approval.

Test: Sampled 30 changes over audit period:
- All had documented approval ✓
- Testing evidence present ✓
- Rollback plans documented ✓
```

### Incident Response (CC7)

```
Control: Security incidents are identified and responded to.

Test: Reviewed incident management process:
- Incidents logged in ticketing system ✓
- Severity classification applied ✓
- Root cause analysis performed ✓
- Lessons learned documented ✓
```

## Implementation Checklist

### Policies & Procedures
- [ ] Information security policy
- [ ] Acceptable use policy
- [ ] Access control policy
- [ ] Incident response plan
- [ ] Business continuity plan
- [ ] Vendor management policy
- [ ] Data classification policy

### Technical Controls
- [ ] MFA for all users
- [ ] Encryption at rest and in transit
- [ ] Centralized logging
- [ ] Intrusion detection
- [ ] Vulnerability management
- [ ] Endpoint protection
- [ ] Network segmentation

### Administrative Controls
- [ ] Background checks
- [ ] Security awareness training
- [ ] Regular access reviews
- [ ] Risk assessments
- [ ] Vendor assessments
- [ ] Penetration testing

### Evidence Collection
- [ ] Access provisioning tickets
- [ ] Change management tickets
- [ ] Training completion records
- [ ] Access review documentation
- [ ] Incident tickets
- [ ] Vulnerability scan reports
- [ ] Penetration test reports

## Audit Preparation Timeline

| Timeframe | Activity |
|-----------|----------|
| 6 months before | Gap assessment |
| 4 months before | Remediate gaps |
| 3 months before | Collect evidence |
| 2 months before | Internal audit |
| 1 month before | Pre-audit with auditor |
| Audit period | External audit |
| After audit | Address findings |

## Common Exceptions

1. **Missing approvals** - Ensure all changes have documented approval
2. **Incomplete access reviews** - Schedule quarterly reviews
3. **Training gaps** - Track completion in HR system
4. **Terminated user access** - Implement offboarding automation
5. **Missing encryption** - Audit all data stores

## AWS Services for SOC 2

| Control Area | AWS Services |
|--------------|-------------|
| Access Control | IAM, SSO, Organizations |
| Logging | CloudTrail, CloudWatch, S3 |
| Encryption | KMS, ACM |
| Monitoring | GuardDuty, Security Hub |
| Availability | Multi-AZ, Auto Scaling |
| Backup | AWS Backup, S3 Glacier |

## Resources

- [AICPA Trust Services Criteria](https://www.aicpa.org/resources/download/2017-trust-services-criteria-with-revised-points-of-focus-2022)
- [SOC 2 Guide](https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/sorhome)
