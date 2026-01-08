# CMMC (Cybersecurity Maturity Model Certification) Notes

## Overview

CMMC is a DoD cybersecurity standard for defense contractors handling:
- **FCI** - Federal Contract Information
- **CUI** - Controlled Unclassified Information

## CMMC 2.0 Levels

| Level | Description | Requirements | Assessment |
|-------|-------------|--------------|------------|
| Level 1 | Foundational | 17 practices (FAR 52.204-21) | Self-assessment |
| Level 2 | Advanced | 110 practices (NIST 800-171) | Third-party or self |
| Level 3 | Expert | 110+ practices (NIST 800-172) | Government assessment |

## Level 2 Control Families (NIST 800-171)

| ID | Family | Controls |
|----|--------|----------|
| AC | Access Control | 22 |
| AU | Audit and Accountability | 9 |
| AT | Awareness and Training | 3 |
| CM | Configuration Management | 9 |
| IA | Identification and Authentication | 11 |
| IR | Incident Response | 3 |
| MA | Maintenance | 6 |
| MP | Media Protection | 9 |
| PE | Physical Protection | 6 |
| PS | Personnel Security | 2 |
| RA | Risk Assessment | 3 |
| CA | Security Assessment | 4 |
| SC | System and Communications Protection | 16 |
| SI | System and Information Integrity | 7 |

## Key Requirements

### Access Control (AC)

**AC.L2-3.1.1** - Limit system access to authorized users
- Implement strong authentication
- Disable default accounts
- Unique user IDs

**AC.L2-3.1.5** - Employ least privilege
- Role-based access control
- Regular access reviews
- Separate admin accounts

**AC.L2-3.1.7** - Prevent non-privileged users from executing privileged functions
- Audit privileged actions
- Implement approval workflows

### Identification & Authentication (IA)

**IA.L2-3.5.3** - Use MFA for local and network access
- Required for all privileged accounts
- Required for remote access to CUI

### System & Communications Protection (SC)

**SC.L2-3.13.8** - Implement cryptographic mechanisms for CUI in transit
- TLS 1.2+
- VPN for remote access

**SC.L2-3.13.16** - Protect CUI at rest
- Encrypt storage
- FIPS 140-2 validated modules

### Audit (AU)

**AU.L2-3.3.1** - Create and retain audit logs
- Log successful and failed access
- Retain for compliance period
- Protect logs from modification

## Implementation Checklist

### Technical Controls
- [ ] MFA enabled for all users
- [ ] Encryption at rest (AES-256)
- [ ] Encryption in transit (TLS 1.2+)
- [ ] Centralized logging (SIEM)
- [ ] Vulnerability scanning
- [ ] Endpoint protection
- [ ] Network segmentation

### Administrative Controls
- [ ] Security awareness training
- [ ] Incident response plan
- [ ] System security plan (SSP)
- [ ] POA&M process
- [ ] Access control procedures
- [ ] Configuration management

### Physical Controls
- [ ] Physical access controls
- [ ] Visitor management
- [ ] Media sanitization procedures

## AWS Services for CMMC

| Requirement | AWS Service |
|-------------|-------------|
| Access Control | IAM, Organizations |
| MFA | IAM MFA, AWS SSO |
| Encryption at Rest | KMS, S3 SSE, EBS encryption |
| Encryption in Transit | ACM, ALB/NLB TLS |
| Audit Logging | CloudTrail, CloudWatch |
| Vulnerability Scanning | Inspector, GuardDuty |
| Configuration Baseline | Config, Systems Manager |
| Incident Response | Security Hub, Detective |

## Documentation Required

1. **System Security Plan (SSP)**
   - System boundaries
   - Control implementation
   - Diagrams

2. **Plan of Action & Milestones (POA&M)**
   - Gaps identified
   - Remediation timeline
   - Responsible parties

3. **Security Assessment Report**
   - Assessment results
   - Findings
   - Risk ratings

## Resources

- [CMMC Official Site](https://dodcio.defense.gov/CMMC/)
- [NIST SP 800-171](https://csrc.nist.gov/publications/detail/sp/800-171/rev-2/final)
- [NIST SP 800-172](https://csrc.nist.gov/publications/detail/sp/800-172/final)
- [CUI Registry](https://www.archives.gov/cui)
