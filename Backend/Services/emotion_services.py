import cv2
import os
import uuid
from deepface import DeepFace

TEMP_DIR = "static/emotion_images"
os.makedirs(TEMP_DIR, exist_ok=True)

def detect_emotion(image):
    if image is None or image.size == 0:
        return {"emotion":"unknown", "confidence":0.0, "emotions":{}}

    image_id = str(uuid.uuid4())
    image_path = os.path.join(TEMP_DIR, f"{image_id}.jpg").replace("\\","/")

    success = cv2.imwrite(image_path, image)
    if not success:
        return {"emotion":"unknown", "confidence":0.0, "emotions":{}}

    try:
        result = DeepFace.analyze(
            img_path=image_path,
            actions=['emotion'],
            enforce_detection=False
        )
        if isinstance(result, list):
            result = result[0]

        emotions = result["emotion"]
        top_emotion = max(emotions, key=emotions.get)
        confidence = emotions[top_emotion]
    except Exception as e:
        print("DeepFace error:", e)
        top_emotion = "unknown"
        confidence = 0.0
        emotions = {}

    # cleanup
    os.remove(image_path)
    return {"emotion": top_emotion, "confidence": confidence, "emotions": emotions}
