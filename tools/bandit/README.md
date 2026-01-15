# Bandit - Python Security Linter

## Overview

Bandit finds common security issues in Python code through AST analysis.

## Installation

```bash
pip install bandit
```

## Basic Usage

```bash
# Scan directory
bandit -r ./src

# Output JSON
bandit -r ./src -f json -o results.json

# Specific severity
bandit -r ./src -ll  # Medium and above
bandit -r ./src -lll # High only

# Specific tests
bandit -r ./src -t B101,B102

# Skip tests
bandit -r ./src -s B101
```

## Configuration

### .bandit file

```yaml
# .bandit
[bandit]
exclude: /tests,/venv
skips: B101,B601
```

### pyproject.toml

```toml
[tool.bandit]
exclude_dirs = ["tests", "venv"]
skips = ["B101"]
```

### bandit.yaml

```yaml
# bandit.yaml
skips: ['B101', 'B601']
exclude_dirs:
  - tests
  - venv
```

## Important Rules

### B101 - Assert Used

```python
# ❌ Flagged - asserts removed in optimized mode
assert user.is_admin, "Not authorized"

# ✅ Fix
if not user.is_admin:
    raise PermissionError("Not authorized")
```

### B102 - exec Used

```python
# ❌ Flagged - code execution
exec(user_input)

# ✅ Fix - avoid exec entirely
```

### B103 - Permissive File Permissions

```python
# ❌ Flagged - world-readable
os.chmod('/etc/passwd', 0o777)

# ✅ Fix - restrictive permissions
os.chmod('secrets.txt', 0o600)
```

### B104 - Bind to All Interfaces

```python
# ❌ Flagged - accessible from any network
socket.bind(('0.0.0.0', 8080))

# ✅ Fix - bind to specific interface
socket.bind(('127.0.0.1', 8080))
```

### B105-B107 - Hardcoded Passwords

```python
# ❌ Flagged
password = "secret123"
api_key = "sk-xxxxx"

# ✅ Fix
password = os.environ.get("DB_PASSWORD")
api_key = os.environ.get("API_KEY")
```

### B301 - Pickle Used

```python
# ❌ Flagged - arbitrary code execution
data = pickle.load(user_file)

# ✅ Fix - use safe format
data = json.load(user_file)
```

### B303 - Weak Hash (MD5/SHA1)

```python
# ❌ Flagged for security use
hash = hashlib.md5(password.encode()).hexdigest()

# ✅ Fix - use strong hash
hash = hashlib.sha256(data.encode()).hexdigest()

# ✅ Or mark as not for security
hash = hashlib.md5(data.encode(), usedforsecurity=False).hexdigest()
```

### B324 - Insecure Hash Functions

```python
# ❌ Flagged
hashlib.new('md5')

# ✅ Fix
hashlib.new('sha256')
```

### B602 - subprocess with shell=True

```python
# ❌ Flagged - command injection risk
subprocess.call(cmd, shell=True)

# ✅ Fix - use list of arguments
subprocess.call(['ls', '-la', path])
```

### B608 - SQL Injection

```python
# ❌ Flagged
query = f"SELECT * FROM users WHERE name = '{name}'"

# ✅ Fix - parameterized query
query = "SELECT * FROM users WHERE name = %s"
cursor.execute(query, (name,))
```

## Suppressing False Positives

### Inline Comments

```python
# nosec comment
password = get_password()  # nosec B105

# With specific rule
data = pickle.loads(trusted_data)  # nosec B301
```

### Skip in Config

```toml
[tool.bandit]
skips = ["B101"]  # assert_used
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Security Scan
  run: |
    pip install bandit
    bandit -r ./src -f json -o bandit-results.json
    bandit -r ./src -ll --exit-zero
```

### Pre-commit

```yaml
repos:
  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ["-r", "src/"]
```

## Common Patterns

### Safe Password Hashing

```python
import bcrypt

def hash_password(password: str) -> bytes:
    """Bandit-compliant password hashing."""
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt())
```

### Safe Subprocess

```python
import shlex
import subprocess

def run_command(cmd: str) -> str:
    """Bandit-compliant subprocess execution."""
    args = shlex.split(cmd)
    result = subprocess.run(
        args,
        capture_output=True,
        text=True,
        timeout=30,
    )
    return result.stdout
```

## References

- [Bandit Documentation](https://bandit.readthedocs.io/)
- [Bandit Plugin List](https://bandit.readthedocs.io/en/latest/plugins/index.html)
- [GitHub Repository](https://github.com/PyCQA/bandit)
