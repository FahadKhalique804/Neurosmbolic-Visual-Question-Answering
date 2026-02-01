# Services/file_service.py
import os, uuid
from datetime import datetime
from PIL import Image
from werkzeug.utils import secure_filename

class FileService:
    def save_file(file, folder, convert_webp=True):
        """
        Save a single file to /static/<folder>, optionally convert to WEBP.
        Returns the saved file path.
        """
        upload_folder = os.path.join("static", folder)
        os.makedirs(upload_folder, exist_ok=True)

        # Unique filename
        filename = f"{uuid.uuid4().hex}_{secure_filename(file.filename)}"
        if convert_webp:
            filename = os.path.splitext(filename)[0] + ".webp"

        file_path = os.path.join(upload_folder, filename)

        if convert_webp:
            img = Image.open(file.stream).convert("RGB")
            img.save(file_path, "WEBP", quality=80)
        else:
            file.save(file_path)

        return file_path