from fastapi import APIRouter, Depends
from auth import get_uid
from models.task import TaskCreate, TaskUpdate
from services.firestore_service import (
    create_task,
    get_tasks,
    update_task,
    delete_task,
)

router = APIRouter()


@router.post("/tasks")
def create(uid: str = Depends(get_uid), body: TaskCreate = ..., task_data=None):
    return create_task(uid, body.model_dump())


@router.get("/tasks")
def list_tasks(uid: str = Depends(get_uid)):
    return get_tasks(uid)


@router.patch("/tasks/{task_id}")
def update(uid: str = Depends(get_uid), task_id: str = ..., body: TaskUpdate = ...):
    updates = {k: v for k, v in body.model_dump().items() if v is not None}
    update_task(uid, task_id, updates)
    return {"status": "updated"}


@router.delete("/tasks/{task_id}")
def delete(uid: str = Depends(get_uid), task_id: str = ...):
    delete_task(uid, task_id)
    return {"status": "deleted"}
