from fastapi import APIRouter, Depends
from pydantic import BaseModel
from auth import get_uid
from services.ai_service import (
    parse_natural_language,
    prioritize_tasks,
    generate_reflection,
)

router = APIRouter()


class NaturalInputRequest(BaseModel):
    text: str


class PrioritizeRequest(BaseModel):
    tasks: list


class ReflectionRequest(BaseModel):
    date: str
    completed: list
    pending: list


@router.post("/natural-input")
def natural_input(uid: str = Depends(get_uid), body: NaturalInputRequest = ...):
    return parse_natural_language(body.text)


@router.post("/prioritize")
def prioritize(uid: str = Depends(get_uid), body: PrioritizeRequest = ...):
    return prioritize_tasks(body.tasks)


@router.post("/reflection")
def reflection(uid: str = Depends(get_uid), body: ReflectionRequest = ...):
    return generate_reflection(body.completed, body.pending, body.date)
