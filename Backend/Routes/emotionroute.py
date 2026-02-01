# emotion/emotion_routes.py

from flask import Blueprint, request, jsonify
import cv2
import numpy as np
from Services.emotion_services import detect_emotion

emotion_routes = Blueprint("emotion_routes", __name__)

@emotion_routes.route('/getEmotion', methods=['POST'])
def get_emotion():
    try:
        if 'image' not in request.files:
            return jsonify({"error": "Image is required"}), 400

        file = request.files['image']
        image = cv2.imdecode(
            np.frombuffer(file.read(), np.uint8),
            cv2.IMREAD_COLOR
        )

        result = detect_emotion(image)

        return jsonify({
            "emotion": result["emotion"],
            "confidence": result["confidence"],
            "emotions": result["emotions"]
        })

    except Exception as e:
        return jsonify({
            "message": "Something went wrong",
            "details": str(e)
        }), 500


@emotion_routes.route('/inemotion', methods=['GET'])
def in_emotion():
    return jsonify({
        "message": "Emotion service is running"
    })