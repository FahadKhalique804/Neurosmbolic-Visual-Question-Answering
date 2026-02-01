import uuid
from PIL import Image
import cv2
import os

class ImageHandler:
    def save_image(self, file, upload_dir='static/AnswerPics', convert_webp=True):
        # Ensure the folder exists
        os.makedirs(upload_dir, exist_ok=True)

        # Generate a unique filename
        filename = f"{uuid.uuid4().hex}_{file.filename}"
        if convert_webp:
            filename = os.path.splitext(filename)[0] + ".webp"

        file_path = os.path.join(upload_dir, filename)

        # Save and optionally convert to WEBP
        if convert_webp:
            img = Image.open(file.stream).convert("RGB")
            img.save(file_path, "WEBP", quality=80)
        else:
            file.save(file_path)

        return file_path

    def load_image(self, path):
        """Load an image using OpenCV"""
        return cv2.imread(path)
