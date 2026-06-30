import json
import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

_MODEL = None


def _get_model(system_instruction: str):
    global _MODEL
    return genai.GenerativeModel(
        "gemini-1.5-flash",
        system_instruction=system_instruction,
        generation_config={"max_output_tokens": 1024},
    )


def _parse_json(text: str) -> dict:
    cleaned = text.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.split("\n", 1)[-1]
        cleaned = cleaned.rsplit("```", 1)[0]
    return json.loads(cleaned.strip())


def generate_daily_plan(tasks: list, available_hours: int) -> dict:
    system_instruction = (
        "You are FlowPlan AI, a personal productivity assistant.\n"
        "Given the user's tasks and available hours, generate a realistic\n"
        "time-blocked daily schedule. Return ONLY valid JSON, no extra text:\n"
        "{\n"
        "  'schedule': [\n"
        "    {'time': '09:00', 'task_id': '', 'title': '',\n"
        "     'duration_minutes': 60, 'notes': ''}\n"
        "  ],\n"
        "  'summary': '',\n"
        "  'tips': ['', '']\n"
        "}"
    )
    model = _get_model(system_instruction)
    try:
        response = model.generate_content(f"Tasks: {tasks}\nAvailable hours: {available_hours}")
        return _parse_json(response.text)
    except Exception:
        return {"schedule": [], "summary": "", "tips": []}


def parse_natural_language(text: str) -> dict:
    system_instruction = (
        "Parse the user's natural language into a structured task.\n"
        "Return ONLY valid JSON, no extra text:\n"
        "{\n"
        "  'title': '',\n"
        "  'description': '',\n"
        "  'deadline': 'ISO datetime string or null',\n"
        "  'priority': 'high or medium or low',\n"
        "  'estimated_duration_minutes': 0,\n"
        "  'tags': []\n"
        "}"
    )
    model = _get_model(system_instruction)
    try:
        response = model.generate_content(text)
        return _parse_json(response.text)
    except Exception:
        return {"title": "", "description": "", "deadline": None, "priority": "medium", "estimated_duration_minutes": 0, "tags": []}


def prioritize_tasks(tasks: list) -> dict:
    system_instruction = (
        "Rerank these tasks by urgency and importance using Eisenhower matrix logic.\n"
        "Return ONLY valid JSON, no extra text:\n"
        "{\n"
        "  'prioritized_tasks': [\n"
        "    {'task_id': '', 'priority_score': 0.0, 'reasoning': ''}\n"
        "  ]\n"
        "}"
    )
    model = _get_model(system_instruction)
    try:
        response = model.generate_content(f"Tasks: {tasks}")
        return _parse_json(response.text)
    except Exception:
        return {"prioritized_tasks": []}


def generate_reflection(completed: list, pending: list, date: str) -> dict:
    system_instruction = (
        "You are a productivity coach. Generate an end-of-day reflection.\n"
        "Return ONLY valid JSON, no extra text:\n"
        "{\n"
        "  'summary': '',\n"
        "  'achievements': [''],\n"
        "  'improvements': [''],\n"
        "  'motivation': ''\n"
        "}"
    )
    model = _get_model(system_instruction)
    try:
        response = model.generate_content(f"Date: {date}\nCompleted: {completed}\nPending: {pending}")
        return _parse_json(response.text)
    except Exception:
        return {"summary": "", "achievements": [], "improvements": [], "motivation": ""}
