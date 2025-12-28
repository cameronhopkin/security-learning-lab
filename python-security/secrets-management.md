# Secrets Management in Python

## The Problem

Secrets (API keys, passwords, tokens) should never be:
- Hardcoded in source code
- Committed to version control
- Logged or printed
- Stored in plain text files

## Solutions by Environment

### Local Development

#### Environment Variables

```python
import os

# Load from environment
DATABASE_URL = os.environ.get("DATABASE_URL")
API_KEY = os.environ.get("API_KEY")

# With validation
def get_required_env(name: str) -> str:
    """Get required environment variable or raise."""
    value = os.environ.get(name)
    if not value:
        raise ValueError(f"Required environment variable {name} not set")
    return value
```

#### python-dotenv

```python
# .env file (add to .gitignore!)
# DATABASE_URL=postgresql://user:pass@localhost/db
# API_KEY=sk-xxxxx

from dotenv import load_dotenv
import os

load_dotenv()  # Load from .env file

DATABASE_URL = os.getenv("DATABASE_URL")
```

#### .env.example Pattern

```bash
# .env.example (commit this)
DATABASE_URL=postgresql://user:password@localhost/dbname
API_KEY=your-api-key-here
SECRET_KEY=generate-a-random-key

# .env (DO NOT commit)
DATABASE_URL=postgresql://admin:realpass@localhost/prod
API_KEY=sk-live-abc123
SECRET_KEY=a1b2c3d4e5f6...
```

### AWS Secrets Manager

```python
import boto3
import json
from functools import lru_cache

@lru_cache(maxsize=None)
def get_secret(secret_name: str, region: str = "us-east-1") -> dict:
    """
    Retrieve secret from AWS Secrets Manager.

    Cached to avoid repeated API calls.
    """
    client = boto3.client("secretsmanager", region_name=region)

    response = client.get_secret_value(SecretId=secret_name)

    if "SecretString" in response:
        return json.loads(response["SecretString"])
    else:
        # Binary secret
        return response["SecretBinary"]

# Usage
secrets = get_secret("prod/myapp/database")
db_password = secrets["password"]
```

### AWS Parameter Store

```python
import boto3
from functools import lru_cache

@lru_cache(maxsize=None)
def get_parameter(name: str, decrypt: bool = True) -> str:
    """Get parameter from AWS SSM Parameter Store."""
    client = boto3.client("ssm")

    response = client.get_parameter(
        Name=name,
        WithDecryption=decrypt
    )

    return response["Parameter"]["Value"]

# Usage
api_key = get_parameter("/prod/myapp/api-key")
```

### HashiCorp Vault

```python
import hvac

def get_vault_secret(path: str) -> dict:
    """Get secret from HashiCorp Vault."""
    client = hvac.Client(
        url=os.environ["VAULT_ADDR"],
        token=os.environ["VAULT_TOKEN"]
    )

    secret = client.secrets.kv.v2.read_secret_version(path=path)
    return secret["data"]["data"]

# Usage
secrets = get_vault_secret("myapp/database")
```

### Azure Key Vault

```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

def get_azure_secret(vault_url: str, secret_name: str) -> str:
    """Get secret from Azure Key Vault."""
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url=vault_url, credential=credential)

    secret = client.get_secret(secret_name)
    return secret.value

# Usage
password = get_azure_secret(
    "https://myvault.vault.azure.net/",
    "database-password"
)
```

## Configuration Class Pattern

```python
from dataclasses import dataclass
from functools import lru_cache
import os

@dataclass
class Config:
    """Application configuration with secrets."""
    database_url: str
    api_key: str
    secret_key: str
    debug: bool = False

    @classmethod
    @lru_cache(maxsize=1)
    def from_environment(cls) -> "Config":
        """Load configuration from environment."""
        return cls(
            database_url=os.environ["DATABASE_URL"],
            api_key=os.environ["API_KEY"],
            secret_key=os.environ["SECRET_KEY"],
            debug=os.environ.get("DEBUG", "").lower() == "true",
        )

# Usage
config = Config.from_environment()
```

## Safe Logging

```python
import logging
import re

class SecretFilter(logging.Filter):
    """Filter to redact secrets from logs."""

    PATTERNS = [
        (r'password=\S+', 'password=***'),
        (r'api_key=\S+', 'api_key=***'),
        (r'token=\S+', 'token=***'),
        (r'secret=\S+', 'secret=***'),
        (r'Bearer \S+', 'Bearer ***'),
        (r'sk-[a-zA-Z0-9]+', 'sk-***'),  # OpenAI keys
        (r'AKIA[A-Z0-9]{16}', 'AKIA***'),  # AWS access keys
    ]

    def filter(self, record):
        message = record.getMessage()
        for pattern, replacement in self.PATTERNS:
            message = re.sub(pattern, replacement, message, flags=re.IGNORECASE)
        record.msg = message
        record.args = ()
        return True

# Setup
logger = logging.getLogger()
logger.addFilter(SecretFilter())
```

## Git Protection

### .gitignore

```gitignore
# Secrets
.env
.env.*
!.env.example
*.pem
*.key
secrets.yaml
secrets.json
credentials.json
```

### Pre-commit Hook with Gitleaks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
```

### Git-secrets

```bash
# Install git-secrets
brew install git-secrets

# Add AWS patterns
git secrets --register-aws

# Scan for secrets
git secrets --scan
```

## Rotation Strategy

```python
from datetime import datetime, timedelta

class RotatingSecret:
    """Handle secret rotation gracefully."""

    def __init__(self, get_secret_fn, rotation_period_days: int = 90):
        self.get_secret = get_secret_fn
        self.rotation_period = timedelta(days=rotation_period_days)
        self._secret = None
        self._fetched_at = None

    @property
    def value(self) -> str:
        """Get current secret value, refreshing if needed."""
        if self._should_refresh():
            self._secret = self.get_secret()
            self._fetched_at = datetime.utcnow()
        return self._secret

    def _should_refresh(self) -> bool:
        if self._secret is None:
            return True
        if self._fetched_at is None:
            return True
        return datetime.utcnow() - self._fetched_at > self.rotation_period
```

## Checklist

- [ ] No secrets in source code
- [ ] .env files in .gitignore
- [ ] Using secrets manager in production
- [ ] Secrets filtered from logs
- [ ] Pre-commit hooks for secret detection
- [ ] Rotation policy defined
- [ ] Access to secrets audited

## References

- [12-Factor App: Config](https://12factor.net/config)
- [AWS Secrets Manager Best Practices](https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html)
- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
