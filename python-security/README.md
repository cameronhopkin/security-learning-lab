# Python Security

Notes and examples for writing secure Python code.

## Topics

1. [Input Validation](./input-validation.md)
2. [SQL Injection Prevention](./sql-injection.md)
3. [Cryptography](./cryptography.md)
4. [Secrets Management](./secrets-management.md)
5. [Secure Deserialization](./deserialization.md)

## Quick Reference

### Common Vulnerabilities

| Vulnerability | CWE | Bandit Rule | Fix |
|--------------|-----|-------------|-----|
| SQL Injection | CWE-89 | B608 | Use parameterized queries |
| Command Injection | CWE-78 | B602, B603 | Avoid shell=True, validate input |
| Hardcoded Secrets | CWE-798 | B105, B106 | Use env vars or secrets manager |
| Insecure Deserialization | CWE-502 | B301, B403 | Use safe formats (JSON), validate |
| Weak Crypto | CWE-327 | B303, B304 | Use SHA-256+, AES |
| Path Traversal | CWE-22 | N/A | Validate paths, use pathlib |

### Secure Coding Checklist

- [ ] All user input validated and sanitized
- [ ] Parameterized queries for database access
- [ ] No hardcoded credentials
- [ ] Strong cryptographic algorithms (SHA-256+, AES-256)
- [ ] Proper error handling (no stack traces to users)
- [ ] Logging without sensitive data
- [ ] Dependencies checked for vulnerabilities
