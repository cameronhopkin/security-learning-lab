# Trivy - Vulnerability Scanner

## Overview

Trivy is a comprehensive security scanner for:
- Container images
- Filesystems
- Git repositories
- Kubernetes clusters
- AWS accounts

## Installation

```bash
# macOS
brew install trivy

# Linux
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Docker
docker run aquasec/trivy
```

## Basic Usage

### Container Image Scanning

```bash
# Scan image
trivy image python:3.11

# Scan with severity filter
trivy image --severity HIGH,CRITICAL python:3.11

# Output JSON
trivy image -f json -o results.json python:3.11

# Ignore unfixed vulnerabilities
trivy image --ignore-unfixed python:3.11
```

### Filesystem Scanning

```bash
# Scan current directory
trivy fs .

# Scan for vulnerabilities and misconfigs
trivy fs --scanners vuln,misconfig .

# Scan for secrets
trivy fs --scanners secret .
```

### Git Repository Scanning

```bash
trivy repo https://github.com/user/repo
trivy repo ./local-repo
```

### Kubernetes Scanning

```bash
# Scan cluster
trivy k8s --report summary cluster

# Scan specific namespace
trivy k8s -n default --report all
```

## Configuration

### trivy.yaml

```yaml
# trivy.yaml
severity:
  - CRITICAL
  - HIGH

scan:
  scanners:
    - vuln
    - misconfig
    - secret

vulnerability:
  ignore-unfixed: true

misconfig:
  policy-paths:
    - ./policies
```

### Ignore File (.trivyignore)

```
# Ignore specific CVEs
CVE-2023-12345
CVE-2023-67890

# Ignore by package
pkg:npm/lodash@4.17.0
```

## Common Scan Types

### Vulnerability Scan

```bash
trivy image --scanners vuln nginx:latest
```

Output:
```
nginx (debian 11.6)
===================
Total: 23 (HIGH: 5, CRITICAL: 2)

┌─────────────────┬────────────────┬──────────┬───────────────────┐
│     Library     │ Vulnerability  │ Severity │  Fixed Version    │
├─────────────────┼────────────────┼──────────┼───────────────────┤
│ openssl         │ CVE-2023-0286  │ CRITICAL │ 1.1.1t-1          │
│ curl            │ CVE-2023-27534 │ HIGH     │ 7.88.1-8          │
└─────────────────┴────────────────┴──────────┴───────────────────┘
```

### Misconfiguration Scan

```bash
trivy config ./terraform/
trivy config ./kubernetes/
trivy config ./dockerfile
```

Output:
```
Dockerfile
==========
Tests: 23 (SUCCESSES: 20, FAILURES: 3)

┌──────────────────┬────────┬──────────────────────────────────────┐
│       Type       │ Result │              Message                 │
├──────────────────┼────────┼──────────────────────────────────────┤
│ Dockerfile       │ FAIL   │ Specify at least 1 USER command     │
│ Dockerfile       │ FAIL   │ Add HEALTHCHECK instruction         │
└──────────────────┴────────┴──────────────────────────────────────┘
```

### Secret Detection

```bash
trivy fs --scanners secret ./
```

Output:
```
secrets (1)
===========
Total: 1 (HIGH: 1)

┌──────────────────┬──────────────────────────────────────────────┐
│    Category      │                    Match                     │
├──────────────────┼──────────────────────────────────────────────┤
│ AWS Access Key   │ AKIA****************                         │
└──────────────────┴──────────────────────────────────────────────┘
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Security Scan

on: [push, pull_request]

jobs:
  trivy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          severity: 'CRITICAL,HIGH'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'
```

### GitLab CI

```yaml
trivy:
  image: aquasec/trivy:latest
  script:
    - trivy fs --exit-code 1 --severity HIGH,CRITICAL .
  allow_failure: false
```

### Docker Build Integration

```dockerfile
# Multi-stage with Trivy scan
FROM aquasec/trivy:latest AS scanner
COPY --from=builder /app /app
RUN trivy fs --exit-code 1 --severity CRITICAL /app

FROM python:3.11-slim
COPY --from=builder /app /app
```

## Common Options

| Option | Description |
|--------|-------------|
| `--severity` | Filter by severity (CRITICAL,HIGH,MEDIUM,LOW) |
| `--ignore-unfixed` | Skip vulnerabilities without fixes |
| `-f, --format` | Output format (table, json, sarif) |
| `--exit-code` | Exit code when vulnerabilities found |
| `--skip-dirs` | Directories to skip |
| `--skip-files` | Files to skip |
| `--timeout` | Scan timeout |
| `--cache-dir` | Cache directory |

## Output Formats

```bash
# Table (default)
trivy image nginx:latest

# JSON
trivy image -f json nginx:latest

# SARIF (for GitHub Code Scanning)
trivy image -f sarif nginx:latest

# CycloneDX SBOM
trivy image -f cyclonedx nginx:latest
```

## Best Practices

1. **Use specific image tags** - Avoid `latest`
2. **Scan in CI/CD** - Block deployments on critical findings
3. **Use .trivyignore** - Document accepted risks
4. **Scan regularly** - New vulnerabilities discovered daily
5. **Combine scan types** - vuln + misconfig + secret

## References

- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [GitHub Repository](https://github.com/aquasecurity/trivy)
- [Trivy GitHub Action](https://github.com/aquasecurity/trivy-action)
