import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from apscheduler.schedulers.background import BackgroundScheduler
from routes.tasks import router as tasks_router
from routes.plans import router as plans_router
from routes.ai import router as ai_router
from routes.notifications import router as notifications_router
from services.fcm_service import send_to_all_users
from firebase_admin_init import db

load_dotenv()

scheduler = BackgroundScheduler()


@asynccontextmanager
async def lifespan(app: FastAPI):
    scheduler.add_job(
        send_to_all_users,
        "cron",
        hour=8,
        minute=0,
        args=["Good morning!", "Your FlowPlan for today is ready 🗓️", db],
    )
    scheduler.add_job(
        send_to_all_users,
        "cron",
        hour=21,
        minute=0,
        args=["How was your day?", "Time for your reflection 📊", db],
    )
    scheduler.start()
    yield
    scheduler.shutdown()


app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(tasks_router, prefix="/tasks")
app.include_router(plans_router, prefix="/plans")
app.include_router(ai_router, prefix="/ai")
app.include_router(notifications_router, prefix="/notifications")


@app.get("/health")
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    import uvicorn

    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port)
