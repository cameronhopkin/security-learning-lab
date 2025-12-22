# Python Cryptography Best Practices

## Golden Rules

1. **Don't roll your own crypto** - Use established libraries
2. **Use modern algorithms** - SHA-256+, AES-256, RSA-2048+
3. **Generate strong random values** - Use `secrets` module
4. **Protect keys** - Never hardcode, use secrets managers

## Recommended Libraries

```python
# For general cryptography
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

# For secure random values
import secrets

# For password hashing (preferred)
import bcrypt
# or
from argon2 import PasswordHasher
```

## Hashing

### Password Hashing (Use bcrypt or Argon2)

```python
import bcrypt

def hash_password(password: str) -> bytes:
    """Hash a password using bcrypt."""
    salt = bcrypt.gensalt(rounds=12)
    return bcrypt.hashpw(password.encode(), salt)

def verify_password(password: str, hashed: bytes) -> bool:
    """Verify a password against its hash."""
    return bcrypt.checkpw(password.encode(), hashed)
```

```python
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

ph = PasswordHasher()

def hash_password_argon2(password: str) -> str:
    """Hash using Argon2id (recommended)."""
    return ph.hash(password)

def verify_password_argon2(password: str, hash: str) -> bool:
    """Verify password against Argon2 hash."""
    try:
        ph.verify(hash, password)
        return True
    except VerifyMismatchError:
        return False
```

### Data Integrity Hashing (SHA-256+)

```python
import hashlib

def hash_data(data: bytes) -> str:
    """Hash data for integrity verification."""
    # SHA-256 is secure for integrity checking
    return hashlib.sha256(data).hexdigest()

def hash_file(filepath: str) -> str:
    """Hash a file's contents."""
    sha256 = hashlib.sha256()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            sha256.update(chunk)
    return sha256.hexdigest()
```

### ❌ Avoid Weak Hashes

```python
# DON'T use for security purposes:
# - MD5 (broken)
# - SHA-1 (deprecated)

# These are ONLY acceptable for non-security uses
# like checksums or cache keys, with usedforsecurity=False:
hashlib.md5(data, usedforsecurity=False)
hashlib.sha1(data, usedforsecurity=False)
```

## Symmetric Encryption (AES)

### Using Fernet (Recommended for Simplicity)

```python
from cryptography.fernet import Fernet

def generate_key() -> bytes:
    """Generate a new encryption key."""
    return Fernet.generate_key()

def encrypt_data(key: bytes, data: bytes) -> bytes:
    """Encrypt data using Fernet (AES-128-CBC + HMAC)."""
    f = Fernet(key)
    return f.encrypt(data)

def decrypt_data(key: bytes, encrypted: bytes) -> bytes:
    """Decrypt Fernet-encrypted data."""
    f = Fernet(key)
    return f.decrypt(encrypted)
```

### AES-GCM (For More Control)

```python
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os

def encrypt_aes_gcm(key: bytes, plaintext: bytes, aad: bytes = None) -> tuple:
    """
    Encrypt using AES-256-GCM.

    Returns: (nonce, ciphertext)
    """
    aesgcm = AESGCM(key)
    nonce = os.urandom(12)  # 96-bit nonce for GCM
    ciphertext = aesgcm.encrypt(nonce, plaintext, aad)
    return nonce, ciphertext

def decrypt_aes_gcm(key: bytes, nonce: bytes, ciphertext: bytes, aad: bytes = None) -> bytes:
    """Decrypt AES-256-GCM encrypted data."""
    aesgcm = AESGCM(key)
    return aesgcm.decrypt(nonce, ciphertext, aad)
```

## Key Derivation

### Deriving Keys from Passwords

```python
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes
import os
import base64

def derive_key(password: str, salt: bytes = None) -> tuple:
    """
    Derive an encryption key from a password.

    Returns: (key, salt)
    """
    if salt is None:
        salt = os.urandom(16)

    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,  # 256 bits
        salt=salt,
        iterations=600_000,  # OWASP 2023 recommendation
    )

    key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
    return key, salt
```

## Secure Random Generation

```python
import secrets

# Generate secure random bytes
random_bytes = secrets.token_bytes(32)

# Generate URL-safe token
api_token = secrets.token_urlsafe(32)

# Generate hex token
hex_token = secrets.token_hex(32)

# Secure random integer
random_int = secrets.randbelow(1000)

# Secure choice from list
secret_word = secrets.choice(["alpha", "bravo", "charlie"])

# DON'T use for security:
# - random module (predictable)
# - os.urandom() is okay but secrets is more explicit
```

## Asymmetric Encryption (RSA)

```python
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization

def generate_rsa_keypair():
    """Generate RSA-2048 key pair."""
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,  # Minimum; use 4096 for high security
    )
    return private_key, private_key.public_key()

def encrypt_rsa(public_key, plaintext: bytes) -> bytes:
    """Encrypt with RSA-OAEP."""
    return public_key.encrypt(
        plaintext,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )

def decrypt_rsa(private_key, ciphertext: bytes) -> bytes:
    """Decrypt RSA-OAEP encrypted data."""
    return private_key.decrypt(
        ciphertext,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )
```

## Common Mistakes

### ❌ Hardcoded Keys

```python
# NEVER do this
KEY = "my-secret-key-12345"
```

### ✅ Load from Environment

```python
import os

KEY = os.environ.get("ENCRYPTION_KEY")
if not KEY:
    raise ValueError("ENCRYPTION_KEY environment variable not set")
```

### ❌ Using ECB Mode

```python
# ECB mode is insecure - identical blocks produce identical ciphertext
# NEVER use AES-ECB
```

### ✅ Use GCM or CBC with HMAC

```python
# GCM provides authentication
# CBC must be used with HMAC for authentication
```

## Quick Reference

| Use Case | Algorithm | Library |
|----------|-----------|---------|
| Password storage | Argon2id, bcrypt | argon2-cffi, bcrypt |
| Data integrity | SHA-256, SHA-3 | hashlib |
| Symmetric encryption | AES-256-GCM | cryptography |
| Asymmetric encryption | RSA-2048+ | cryptography |
| Key derivation | PBKDF2, Argon2 | cryptography, argon2 |
| Random tokens | secrets.token_* | secrets |

## References

- [Cryptography.io Documentation](https://cryptography.io/)
- [OWASP Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
