import os
import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore  # 1. Added this import

# Get env variables
cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
cred_json_string = os.environ.get("FIREBASE_CREDENTIALS_JSON")

if cred_json_string:
    # Safest method for production: Parse the raw JSON string directly
    cred_dict = json.loads(cred_json_string)
    cred = credentials.Certificate(cred_dict)
elif cred_path and os.path.exists(cred_path):
    # Fallback for local development using the file path
    cred = credentials.Certificate(cred_path)
else:
    raise ValueError("Neither FIREBASE_CREDENTIALS_JSON nor a valid FIREBASE_CREDENTIALS_PATH is set.")

firebase_admin.initialize_app(cred)

# 2. Added this line so firestore_service.py can import 'db'
db = firestore.client()