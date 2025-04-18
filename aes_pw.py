from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
import base64
import os
import getpass

# Generate random 32-byte key (AES-256) and 16-byte IV
key = os.urandom(32)
iv = os.urandom(16)

# Securely prompt for password
password = getpass.getpass("[*] Enter password to encrypt: ").encode()

# Pad and encrypt
cipher = AES.new(key, AES.MODE_CBC, iv)
ciphertext = cipher.encrypt(pad(password, AES.block_size))

# Output in base64
print("Key (base64):", base64.b64encode(key).decode())
print("IV (base64):", base64.b64encode(iv).decode())
print("Encrypted (base64):", base64.b64encode(ciphertext).decode())
