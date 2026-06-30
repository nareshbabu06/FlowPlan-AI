from google.cloud.firestore import SERVER_TIMESTAMP
from firebase_admin_init import db


def create_task(uid: str, task_data: dict) -> dict:
    doc_ref = db.collection("users").document(uid).collection("tasks").document()
    task_data["created_at"] = SERVER_TIMESTAMP
    doc_ref.set(task_data)
    task = doc_ref.get().to_dict()
    task["id"] = doc_ref.id
    return task


def get_tasks(uid: str) -> list[dict]:
    docs = (
        db.collection("users")
        .document(uid)
        .collection("tasks")
        .stream()
    )
    tasks = []
    for doc in docs:
        task = doc.to_dict()
        task["id"] = doc.id
        tasks.append(task)
    return tasks


def update_task(uid: str, task_id: str, updates: dict) -> None:
    doc_ref = (
        db.collection("users")
        .document(uid)
        .collection("tasks")
        .document(task_id)
    )
    doc_ref.update(updates)


def delete_task(uid: str, task_id: str) -> None:
    doc_ref = (
        db.collection("users")
        .document(uid)
        .collection("tasks")
        .document(task_id)
    )
    doc_ref.delete()
