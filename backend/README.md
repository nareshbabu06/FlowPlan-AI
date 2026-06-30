# FlowPlan AI — Backend

FastAPI backend for the FlowPlan AI task management application. Provides task CRUD, AI-powered daily planning, natural language input parsing, and push notifications via Firebase Cloud Messaging.

## Local Setup

1. **Clone the repo and navigate to `backend/`**

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate   # Linux/macOS
   venv\Scripts\activate      # Windows
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set environment variables** – create a `.env` file in `backend/`:
   ```env
   GEMINI_API_KEY=your_gemini_api_key
   FIREBASE_CREDENTIALS_PATH=path/to/serviceAccountKey.json
   FCM_SERVER_KEY=your_fcm_server_key
   GOOGLE_CLOUD_PROJECT=your_firebase_project_id
   ```

5. **Place your Firebase service account key** at the path specified in `FIREBASE_CREDENTIALS_PATH`.

6. **Run the server**
   ```bash
   python main.py
   ```
   The API will be available at `http://localhost:8000`.

## Environment Variables

| Variable                  | Description                              |
|---------------------------|------------------------------------------|
| `GEMINI_API_KEY`          | API key for Google Gemini AI             |
| `FIREBASE_CREDENTIALS_PATH` | Path to Firebase service account JSON  |
| `FCM_SERVER_KEY`          | Firebase Cloud Messaging server key      |
| `GOOGLE_CLOUD_PROJECT`    | Firebase / Google Cloud project ID       |

## API Endpoints

- `GET  /health` – Health check
- `POST /tasks` – Create a task
- `GET  /tasks` – List tasks
- `PATCH /tasks/{id}` – Update a task
- `DELETE /tasks/{id}` – Delete a task
- `POST /plans/generate` – Generate daily plan
- `POST /plans/save` – Save a plan
- `GET  /plans/{date}` – Get plan by date
- `POST /ai/natural-input` – Parse natural language
- `POST /ai/prioritize` – Prioritize tasks
- `POST /ai/reflection` – Generate reflection
- `POST /notifications/register` – Register FCM token
