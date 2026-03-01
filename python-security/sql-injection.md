# SQL Injection Prevention in Python

## The Problem

SQL injection occurs when untrusted data is sent to an interpreter as part of a command or query.

## Vulnerable Code Examples

### ❌ String Formatting (NEVER DO THIS)

```python
# VULNERABLE - String concatenation
def get_user_bad(username):
    query = "SELECT * FROM users WHERE username = '" + username + "'"
    cursor.execute(query)
    return cursor.fetchone()

# VULNERABLE - f-strings
def get_user_bad_fstring(username):
    query = f"SELECT * FROM users WHERE username = '{username}'"
    cursor.execute(query)
    return cursor.fetchone()

# VULNERABLE - % formatting
def get_user_bad_percent(username):
    query = "SELECT * FROM users WHERE username = '%s'" % username
    cursor.execute(query)
    return cursor.fetchone()
```

**Attack:** `username = "'; DROP TABLE users; --"`

## Secure Solutions

### ✅ Parameterized Queries

```python
# SECURE - Using placeholders
def get_user_secure(username):
    query = "SELECT * FROM users WHERE username = %s"
    cursor.execute(query, (username,))
    return cursor.fetchone()

# SECURE - Named parameters
def get_user_named(username):
    query = "SELECT * FROM users WHERE username = :username"
    cursor.execute(query, {"username": username})
    return cursor.fetchone()
```

### ✅ SQLAlchemy ORM

```python
from sqlalchemy import select
from sqlalchemy.orm import Session

# SECURE - ORM query
def get_user_orm(session: Session, username: str):
    stmt = select(User).where(User.username == username)
    return session.execute(stmt).scalar_one_or_none()

# SECURE - ORM filter
def search_users_orm(session: Session, search_term: str):
    return session.query(User).filter(
        User.name.ilike(f"%{search_term}%")
    ).all()
```

### ✅ Django ORM

```python
from django.db.models import Q

# SECURE - Django ORM
def get_user_django(username):
    return User.objects.get(username=username)

# SECURE - Complex query
def search_users_django(term):
    return User.objects.filter(
        Q(name__icontains=term) | Q(email__icontains=term)
    )
```

## When You Must Use Raw SQL

Sometimes raw SQL is necessary. Use it safely:

```python
from sqlalchemy import text

# SECURE - Raw SQL with bound parameters
def custom_query(session, status, min_age):
    query = text("""
        SELECT * FROM users
        WHERE status = :status
        AND age >= :min_age
    """)
    return session.execute(
        query,
        {"status": status, "min_age": min_age}
    ).fetchall()
```

## Input Validation (Defense in Depth)

Even with parameterized queries, validate input:

```python
import re

def validate_username(username: str) -> bool:
    """Validate username format."""
    # Only allow alphanumeric and underscore, 3-20 chars
    pattern = r'^[a-zA-Z0-9_]{3,20}$'
    return bool(re.match(pattern, username))

def get_user_validated(username: str):
    if not validate_username(username):
        raise ValueError("Invalid username format")

    query = "SELECT * FROM users WHERE username = %s"
    cursor.execute(query, (username,))
    return cursor.fetchone()
```

## Testing for SQL Injection

```python
import pytest

class TestSQLInjection:
    """Test that SQL injection attempts are handled safely."""

    PAYLOADS = [
        "'; DROP TABLE users; --",
        "' OR '1'='1",
        "' UNION SELECT * FROM passwords --",
        "1; DELETE FROM users",
        "' AND 1=1 --",
    ]

    def test_login_sql_injection(self, client):
        for payload in self.PAYLOADS:
            response = client.post("/login", data={
                "username": payload,
                "password": "test"
            })
            # Should not cause error or unexpected behavior
            assert response.status_code in [200, 401, 400]
```

## Bandit Detection

Bandit rule B608 detects SQL injection:

```bash
bandit -r . -t B608
```

## Key Takeaways

1. **ALWAYS use parameterized queries**
2. **NEVER concatenate user input into SQL**
3. **Use ORMs when possible**
4. **Validate input as defense in depth**
5. **Test with injection payloads**

## References

- [OWASP SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)
- [CWE-89](https://cwe.mitre.org/data/definitions/89.html)
- [SQLAlchemy Security](https://docs.sqlalchemy.org/en/20/core/sqlelement.html#sqlalchemy.sql.expression.text)
