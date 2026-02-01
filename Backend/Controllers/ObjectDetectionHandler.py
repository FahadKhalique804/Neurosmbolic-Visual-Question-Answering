import cv2
from ultralytics import YOLO

class ObjectDetectionHandler:
    def __init__(self, model_path=r'D:\PyCharm Project\NS_VQA\modelsNSVQA\last.pt'):
        self.model = YOLO(model_path)

    def detect_objects(self, image_path):
        print("Detecting Objects")
        image = cv2.imread(image_path)
        results = self.model.predict(image_path, show=False)
        boxes = results[0].boxes
        detected = []
        for i, box in enumerate(boxes):
            cls_id = int(box.cls[0].item())
            label = results[0].names[cls_id]
            x_center, y_center, w, h = box.xywh[0].tolist()
            x_min = int(x_center - w / 2)
            y_min = int(y_center - h / 2)
            detected.append({
                'label': label,
                'bbox': [x_min, y_min, int(w), int(h)]
            })
        return detected