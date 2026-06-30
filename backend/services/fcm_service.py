from firebase_admin import messaging


def send_notification(token: str, title: str, body: str) -> None:
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        token=token,
    )
    messaging.send(message)


def send_to_all_users(title: str, body: str, db) -> None:
    users = db.collection("users").stream()
    for user in users:
        user_data = user.to_dict()
        token = user_data.get("fcm_token")
        if token:
            try:
                send_notification(token, title, body)
            except Exception:
                pass
