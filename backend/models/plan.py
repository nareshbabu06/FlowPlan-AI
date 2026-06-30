from pydantic import BaseModel
from typing import Optional


class PlanScheduleItem(BaseModel):
    time: str
    task_id: str = ""
    title: str = ""
    duration_minutes: int = 0
    notes: str = ""


class Plan(BaseModel):
    date: str
    schedule: list[PlanScheduleItem] = []
    ai_summary: str = ""
    tips: list[str] = []
    total_planned_hours: float = 0.0
