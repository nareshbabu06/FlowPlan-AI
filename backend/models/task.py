from enum import Enum
from pydantic import BaseModel, Field
from typing import Optional


class Priority(str, Enum):
    high = "high"
    medium = "medium"
    low = "low"


class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    deadline: Optional[str] = None
    priority: Priority
    tags: list[str] = Field(default_factory=list)
    estimated_duration_minutes: Optional[int] = None


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    deadline: Optional[str] = None
    priority: Optional[Priority] = None
    tags: Optional[list[str]] = None
    estimated_duration_minutes: Optional[int] = None
