# Services/image_service.py
from datetime import datetime
from Services.file_service import FileService
from Models.ContactPics import ContactPicsModel

class ImageService:
    @staticmethod
    def save_contact_images(files, contact_id):
        """Save images under ContactPics and record in DB"""
        saved_paths = []
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        for file in files:
            if file and file.filename:
                path = FileService.save_file(file, "ContactPics", convert_webp=True)
                ContactPicsModel().create_pic(contact_id, path, now)  # DB record
                saved_paths.append(path)

        return saved_paths

    @staticmethod
    def save_assistant_image(file):
        """Save assistant-related images under AssistantPics"""
        return FileService.save_file(file, "AssistantPics", convert_webp=True)

    @staticmethod
    def save_answer_images(files, answer_id):
        """Save answer images under AnswerPics, with DB entry if needed"""
        saved_paths = []
        for file in files:
            if file and file.filename:
                path = FileService.save_file(file, "AnswerPics", convert_webp=True)
                # Optional DB save here
                saved_paths.append(path)
        return saved_paths