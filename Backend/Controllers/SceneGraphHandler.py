import math
try:
    from ultralytics import YOLO

    YOLO_AVAILABLE = True
except ImportError:
    YOLO_AVAILABLE = False
    print("Warning: 'ultralytics' module not found. Object detection will not work, but logic is accessible.")


class SceneGraphHandler:
    def __init__(self, model_path=None, image_height=720, image_width=1280, near_thresh=140, overlap_thresh=0.1):
        if model_path and YOLO_AVAILABLE:
            self.model = YOLO(model_path)
        else:
            self.model = None

        self.image_height = image_height
        self.image_width = image_width
        self.near_thresh = near_thresh
        self.overlap_thresh = overlap_thresh

    def get_bbox_center(self, bbox):
        x, y, w, h = bbox
        return x + w / 2, y + h / 2

    def get_depth_score_feature(self, bbox):
        """
        Simple depth heuristic: Lower Y-bottom = Closer to camera.
        Returns the y-coordinate of the bottom edge.
        Higher value = Closer (since Y increases downwards).
        """
        x, y, w, h = bbox
        return y + h

    def compute_iou(self, boxA, boxB):
        Ax1, Ay1, Aw, Ah = boxA
        Ax2, Ay2 = Ax1 + Aw, Ay1 + Ah
        Bx1, By1, Bw, Bh = boxB
        Bx2, By2 = Bx1 + Bw, By1 + Bh

        xA = max(Ax1, Bx1)
        yA = max(Ay1, By1)
        xB = min(Ax2, Bx2)
        yB = min(Ay2, By2)

        interWidth = max(0, xB - xA)
        interHeight = max(0, yB - yA)
        interArea = interWidth * interHeight

        areaA = Aw * Ah
        areaB = Bw * Bh

        iou = interArea / float(areaA + areaB - interArea + 1e-6)
        return iou

    def get_euclidean_distance(self, bbox1, bbox2):
        cx1, cy1 = self.get_bbox_center(bbox1)
        cx2, cy2 = self.get_bbox_center(bbox2)
        return math.sqrt((cx1 - cx2) ** 2 + (cy1 - cy2) ** 2)

    def get_relation(self, obj1, obj2):
        box1 = obj1['bbox']
        box2 = obj2['bbox']

        iou = self.compute_iou(box1, box2)
        dist = self.get_euclidean_distance(box1, box2)

        cx1, cy1 = self.get_bbox_center(box1)
        cx2, cy2 = self.get_bbox_center(box2)

        # Dimensions
        w1, h1 = box1[2], box1[3]
        w2, h2 = box2[2], box2[3]

        # Top/Bottom edges
        top1, bottom1 = box1[1], box1[1] + h1
        top2, bottom2 = box2[1], box2[1] + h2

        # Directional Deltas
        dx = cx2 - cx1  # Positive if obj2 is Right
        dy = cy2 - cy1  # Positive if obj2 is Down (Below)

        # ---------------------------------------------------------
        # 1. CHECK "ON" (Vertical Support)
        # ---------------------------------------------------------
        # Obj1 (Top) ON Obj2 (Bottom)
        # Conditions:
        # - Physically above: cy1 < cy2
        # - Good horizontal alignment
        # - Vertical proximity: bottom of 1 is near top of 2
        # REFINEMENT: Allow some overlap (perspective often places cup slightly 'inside' table box)

        x_overlap = min(box1[0] + w1, box2[0] + w2) - max(box1[0], box2[0])
        horizontal_overlap_ratio = x_overlap / float(min(w1, w2) + 1e-6)

        # Check if obj1 is smaller (support logic)
        is_smaller = (w1 * h1) < (w2 * h2) * 0.8

        if horizontal_overlap_ratio > 0.3 and cy1 < cy2:
            # Vertical Check:
            # Bottom1 should be close to Top2 OR inside the top region of Box2
            gap = top2 - bottom1
            # "On" usually means bottom1 is >= top2 (gap <= 0) but not too deep
            # Allow bottom1 to sink into obj2 up to 30% of obj2's height (perspective)
            # Allow bottom1 to float above obj2 up to 10% of obj2's height
            if -h2 * 0.4 < gap < h2 * 0.1:  # or bottom1 is roughly at top2
                return "on"
            # Support case: sitting strictly inside the bounding box but at the top
            if bottom1 > top2 and bottom1 < top2 + (h2 * 0.5):
                # Stronger check: is it smaller?
                if is_smaller:
                    return "on"

        # ---------------------------------------------------------
        # 2. CHECK "IN FRONT OF" / "BEHIND" (Partial Occlusion)
        # ---------------------------------------------------------
        # If overlapping significantly
        if iou > self.overlap_thresh:
            y_bottom1 = self.get_depth_score_feature(box1)
            y_bottom2 = self.get_depth_score_feature(box2)

            # Whichever bottom is lower (higher Y) is clearly in front
            diff = y_bottom1 - y_bottom2

            # Threshold: must be significantly lower (e.g., 5% of img height or simple pixel relative)
            # Normalizing by object height helps robustness
            avg_h = (h1 + h2) / 2

            if diff > avg_h * 0.1:
                return "behind"
            elif diff < -avg_h * 0.1:
                return "in_front_of"

        # ---------------------------------------------------------
        # 3. CHECK "NEAR"
        # ---------------------------------------------------------
        # Distance-based, if not overlapping much
        if dist < self.near_thresh:
            return "near"

        # ---------------------------------------------------------
        # 4. DIRECTIONAL (Fallback)
        # ---------------------------------------------------------
        # If mainly horizontal difference
        if abs(dx) > abs(dy):
            return "left_of" if dx > 0 else "right_of"
        else:
            return "above" if dy > 0 else "below"

    def build_adjacency_matrix(self, objects):
        """
        Builds a matrix where M[i][j] is the relation from object i to object j.
        """
        n = len(objects)
        labels = [obj['label'] for obj in objects]

        matrix = [[None] * (n + 1) for _ in range(n + 1)]
        matrix[0][0] = ""
        for i in range(n):
            matrix[0][i + 1] = labels[i]
            matrix[i + 1][0] = labels[i]

        for i in range(n):
            for j in range(n):
                if i == j:
                    matrix[i + 1][j + 1] = "self"
                    continue

                rel = self.get_relation(objects[i], objects[j])
                matrix[i + 1][j + 1] = rel

        return matrix

    def detect_objects(self, image_path):
        if not self.model:
            print("Model not loaded.")
            return []

        results = self.model.predict(image_path, show=False)
        boxes = results[0].boxes

        detected = []
        for box in boxes:
            cls_id = int(box.cls[0].item())
            label = results[0].names[cls_id]

            x_c, y_c, w, h = box.xywh[0].tolist()
            x = int(x_c - w / 2)
            y = int(y_c - h / 2)

            detected.append({
                "label": label,
                "bbox": [x, y, int(w), int(h)],
                "confidence": float(box.conf[0].item())
            })

        return detected

# ===================== Test =====================
if __name__ == "__main__":
    model_path = r"D:\PyCharm Project\NS_VQA\modelsNSVQA\last.pt"
    image_path = r"C:\Users\PC\Downloads\khan.jpg"

    handler = SceneGraphHandler(
        model_path=model_path,
        image_height=720,
        image_width=1280
    )

    objects = handler.detect_objects(image_path)

    print("\nDetected Objects:")
    for obj in objects:
        print(obj)

    print("\nRelations:")
    for i, obj1 in enumerate(objects):
        for j, obj2 in enumerate(objects):
            if i != j:
                rel = handler.get_relation(obj1, obj2)
                print(f"{obj1['label']} -> {obj2['label']} : {rel}")

    print("\nAdjacency Matrix:")
    matrix = handler.build_adjacency_matrix(objects)
    for row in matrix:
        print(row)