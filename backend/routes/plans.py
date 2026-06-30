from fastapi import APIRouter, Depends
from pydantic import BaseModel
from auth import get_uid
from services.firestore_service import get_tasks
from services.ai_service import generate_daily_plan
from firebase_admin_init import db

router = APIRouter()


class GenerateRequest(BaseModel):
    date: str
    available_hours: int


@router.post("/generate")
def generate(uid: str = Depends(get_uid), body: GenerateRequest = ...):
    tasks = get_tasks(uid)
    plan = generate_daily_plan(tasks, body.available_hours)
    plan["date"] = body.date
    return plan


@router.post("/save")
def save(uid: str = Depends(get_uid), plan: dict = ...):
    date = plan.get("date")
    if not date:
        return {"error": "date is required"}
    doc_ref = db.collection("users").document(uid).collection("plans").document(date)
    doc_ref.set(plan)
    return {"status": "saved", "date": date}


@router.get("/{date}")
def get(uid: str = Depends(get_uid), date: str = ...):
    doc = db.collection("users").document(uid).collection("plans").document(date).get()
    if not doc.exists:
        return {"error": "plan not found"}
    return doc.to_dict()
