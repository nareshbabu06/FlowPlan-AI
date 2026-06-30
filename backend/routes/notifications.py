from fastapi import APIRouter, Depends
from pydantic import BaseModel
from auth import get_uid
from firebase_admin_init import db

router = APIRouter()


class RegisterTokenRequest(BaseModel):
    fcm_token: str


@router.post("/register")
def register_token(req: RegisterTokenRequest, uid: str = Depends(get_uid)):
    db.collection("users").document(uid).set(
        {"fcm_token": req.fcm_token}, merge=True
    )
    return {"status": "ok"}
