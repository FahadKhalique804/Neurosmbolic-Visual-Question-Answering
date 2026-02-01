def to_python(o):
    if isinstance(o, np.generic):
        return o.item()
    if isinstance(o, np.ndarray):
        return o.tolist()
    if isinstance(o, dict):
        return {k: to_python(v) for k, v in o.items()}
    if isinstance(o, list):
        return [to_python(i) for i in o]
    return o

from mtcnn import MTCNN

detector = MTCNN()

import cv2
from collections import Counter
from matplotlib.colors import CSS4_COLORS
from Services.emotion_services import detect_emotion
from mtcnn import MTCNN
import numpy as np

class PropertyHandler:

    def __init__(self):
        self.class_names = ['angry', 'disgust', 'fear', 'happy', 'neutral', 'sad', 'surprise']
        # Keep Haar as fallback
        self.face_cascade = cv2.CascadeClassifier(
            cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
        )
        # Initialize MTCNN detector
        self.mtcnn = MTCNN()

    # ================================================================
    # FACE DETECTION USING HAAR (fallback)
    # ================================================================
    def detect_face_haar(self, image, pad=10):
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        faces = self.face_cascade.detectMultiScale(
            gray,
            scaleFactor=1.2,
            minNeighbors=5,
            minSize=(60, 60)
        )
        if len(faces) == 0:
            return None
        x, y, w, h = faces[0]
        pad = max(10, int(0.1 * min(w, h)))
        y1, y2 = max(0, y - pad), min(image.shape[0], y + h + pad)
        x1, x2 = max(0, x - pad), min(image.shape[1], x + w + pad)
        return image[y1:y2, x1:x2]

    # ================================================================
    # FACE DETECTION USING MTCNN
    # ================================================================
    def detect_face_mtcnn(self, crop):
        result = self.mtcnn.detect_faces(crop)
        if len(result) == 0:
            return None
        x, y, w, h = result[0]['box']
        # Ensure coordinates are within image bounds
        x1, y1 = max(0, x), max(0, y)
        x2, y2 = min(crop.shape[1], x + w), min(crop.shape[0], y + h)
        return crop[y1:y2, x1:x2]

    # ================================================================
    # MAIN METHOD
    # ================================================================
    def assign_properties(self, image, detections):
        print("Assigning properties to detections...")

        for det in detections:
            x, y, w, h = det['bbox']
            # Crop object with padding
            pad = 5
            y1, y2 = max(0, y - pad), min(image.shape[0], y + h + pad)
            x1, x2 = max(0, x - pad), min(image.shape[1], x + w + pad)
            crop = image[y1:y2, x1:x2]

            # COLOR
            det['color'] = self.detect_dominant_color_name(crop)

            # SHAPE
            det['shape'] = self.get_shape(w, h)

            # EMOTION (ONLY FOR PERSON)
            if det.get('label', '').lower() == "person":
                face = self.detect_face_mtcnn(crop)
                if face is None or face.shape[0] < 48:  # height too small
                    face = crop[:int(0.3 * crop.shape[0]), :]  # take top 30% as fallback

                if face is not None:
                    face_rgb = cv2.cvtColor(face, cv2.COLOR_BGR2RGB)
                    emo_data = detect_emotion(face_rgb)
                else:
                    emo_data = {"emotion": "unknown", "confidence": 0.0, "emotions": {}}
                det['emotion'] = emo_data["emotion"]
            else:
                det['emotion'] = "not_applicable"

        return detections

    # ================================================================
    # COLOR DETECTION
    # ================================================================
    def detect_dominant_color_name(self, crop):
        try:
            crop = cv2.resize(crop, (50, 50))
            pixels = crop.reshape(-1, 3)
            pixels = [tuple(int(c) for c in p) for p in pixels]
            dominant_rgb = Counter(pixels).most_common(1)[0][0]
            return self.closest_color(dominant_rgb)
        except:
            return "unknown"

    def closest_color(self, rgb):
        min_dist = float("inf")
        closest = "unknown"
        for name, hex_value in CSS4_COLORS.items():
            r_c, g_c, b_c = tuple(int(hex_value.lstrip('#')[i:i+2], 16) for i in (0, 2, 4))
            dist = sum((comp1 - comp2) ** 2 for comp1, comp2 in zip(rgb, (r_c, g_c, b_c)))
            if dist < min_dist:
                min_dist = dist
                closest = name
        return closest

    # ================================================================
    # SHAPE PROPERTY
    # ================================================================
    def get_shape(self, width, height):
        ratio = float(width) / float(height) if height != 0 else 0
        if 0.9 < ratio < 1.1:
            return "square"
        elif ratio > 1.5:
            return "wide"
        elif ratio < 0.7:
            return "tall"
        else:
            return "rectangle"