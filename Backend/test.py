# import math
# import cv2
# from ultralytics import YOLO
#
# class SceneGraphHandler:
#     def __init__(self, model_path, image_height=720, near_thresh=50, overlap_thresh=0.2):
#         """
#         model_path: path to your YOLO model
#         image_height: height of the image (for scaling)
#         near_thresh: pixel distance to consider objects 'near'
#         overlap_thresh: fraction of overlap to consider for 'in_front_of/behind'
#         """
#         self.model = YOLO(model_path)
#         self.image_height = image_height
#         self.near_thresh = near_thresh
#         self.overlap_thresh = overlap_thresh
#
#     def get_center(self, bbox):
#         x, y, w, h = bbox
#         return x + w / 2, y + h / 2
#
#     def compute_overlap_ratio(self, A, B):
#         """Compute the horizontal and vertical overlap ratio between two boxes"""
#         Ax1, Ay1, Aw, Ah = A
#         Bx1, By1, Bw, Bh = B
#
#         Ax2, Ay2 = Ax1 + Aw, Ay1 + Ah
#         Bx2, By2 = Bx1 + Bw, By1 + Bh
#
#         x_overlap = max(0, min(Ax2, Bx2) - max(Ax1, Bx1))
#         y_overlap = max(0, min(Ay2, By2) - max(Ay1, By2))
#
#         x_ratio = x_overlap / min(Aw, Bw)
#         y_ratio = y_overlap / min(Ah, Bh)
#         return max(x_ratio, y_ratio)
#
#     def get_depth_score(self, bbox):
#         """Estimate depth from bbox size and vertical position (smaller + higher = farther)"""
#         x, y, w, h = bbox
#         area = w * h
#         cy = y + h / 2
#         return (cy / self.image_height) * 0.5 + (1 / (area + 1e-6)) * 0.5
#
#     def get_spatial_relation(self, objA, objB):
#         Ax, Ay, Aw, Ah = objA['bbox']
#         Bx, By, Bw, Bh = objB['bbox']
#
#         cxA, cyA = self.get_center(objA['bbox'])
#         cxB, cyB = self.get_center(objB['bbox'])
#
#         dx = cxB - cxA
#         dy = cyB - cyA
#
#         # LEFT / RIGHT
#         if abs(dx) > max(Aw, Bw) * 0.25:
#             if dx > 0:
#                 return "left_of"
#             else:
#                 return "right_of"
#
#         # ABOVE / BELOW
#         if abs(dy) > max(Ah, Bh) * 0.25:
#             if dy > 0:
#                 return "above"
#             else:
#                 return "below"
#
#         # IN FRONT OF / BEHIND (depth estimation)
#         depthA = self.get_depth_score(objA['bbox'])
#         depthB = self.get_depth_score(objB['bbox'])
#         if depthA + 0.05 < depthB:
#             return "in_front_of"
#         if depthA - 0.05 > depthB:
#             return "behind"
#
#         # NEAR (proximity check)
#         distance = math.sqrt(dx ** 2 + dy ** 2)
#         if distance < self.near_thresh:
#             return "near"
#
#         return "unknown"
#
#     def build_adjacency_matrix(self, objects):
#         """Build adjacency matrix with spatial relations"""
#         n = len(objects)
#         matrix = [['' for _ in range(n + 1)] for _ in range(n + 1)]
#         labels = [f"{obj['label']}_{i}" for i, obj in enumerate(objects)]
#
#         # Header
#         matrix[0][0] = ''
#         for i in range(n):
#             matrix[0][i + 1] = labels[i]
#             matrix[i + 1][0] = labels[i]
#
#         # Fill matrix
#         for i, objA in enumerate(objects):
#             for j, objB in enumerate(objects):
#                 if i == j:
#                     continue
#                 matrix[i + 1][j + 1] = self.get_spatial_relation(objA, objB)
#
#         return matrix
#
#     def detect_objects(self, image_path):
#         """Detect objects using YOLO model"""
#         results = self.model.predict(image_path, show=False)
#         detected = []
#         for i, box in enumerate(results[0].boxes):
#             cls_id = int(box.cls[0].item())
#             label = results[0].names[cls_id]
#             x_center, y_center, w, h = box.xywh[0].tolist()
#             x_min = int(x_center - w / 2)
#             y_min = int(y_center - h / 2)
#             detected.append({'label': label, 'bbox': [x_min, y_min, int(w), int(h)]})
#         return detected
#
# # ===================== Example Usage =====================
#
# if __name__ == "__main__":
#     image_path = "C:\\Users\PC\Downloads\p1.jpg"
#     model_path = "yolov8n.pt"
#
#     scene_handler = SceneGraphHandler(model_path)
#     objects = scene_handler.detect_objects(image_path)
#
#     for i, objA in enumerate(objects):
#         for j, objB in enumerate(objects):
#             if i != j:
#                 relation = scene_handler.get_spatial_relation(objA, objB)
#                 print(f"{objA['label']} -> {objB['label']}: {relation}")
#
#     matrix = scene_handler.build_adjacency_matrix(objects)
#     print("\nAdjacency Matrix:")
#     for row in matrix:
#         print(row)


# import math
# import cv2
# from ultralytics import YOLO
#
# class SceneGraphHandler:
#     def __init__(self, model_path, image_height=720, near_thresh=50, overlap_thresh=0.2):
#         """
#         model_path: path to your YOLO model
#         image_height: height of the image (for scaling)
#         near_thresh: pixel distance to consider objects 'near'
#         overlap_thresh: fraction of overlap to consider for 'in_front_of/behind'
#         """
#         self.model = YOLO(model_path)
#         self.image_height = image_height
#         self.near_thresh = near_thresh
#         self.overlap_thresh = overlap_thresh
#
#     def get_center(self, bbox):
#         x, y, w, h = bbox
#         return x + w / 2, y + h / 2
#
#     def compute_overlap_ratio(self, A, B):
#         """Compute horizontal and vertical overlap ratio between two bounding boxes."""
#         Ax1, Ay1, Aw, Ah = A
#         Bx1, By1, Bw, Bh = B
#
#         Ax2, Ay2 = Ax1 + Aw, Ay1 + Ah
#         Bx2, By2 = Bx1 + Bw, By1 + Bh
#
#         x_overlap = max(0, min(Ax2, Bx2) - max(Ax1, Bx1))
#         y_overlap = max(0, min(Ay2, By2) - max(Ay1, By2))
#
#         x_ratio = x_overlap / min(Aw, Bw)
#         y_ratio = y_overlap / min(Ah, Bh)
#         return max(x_ratio, y_ratio)
#
#     def get_depth_score(self, bbox):
#         """Estimate depth from bbox size and vertical position (smaller + higher = farther)."""
#         x, y, w, h = bbox
#         area = w * h
#         cy = y + h / 2
#         return (cy / self.image_height) * 0.5 + (1 / (area + 1e-6)) * 0.5
#
#     def get_spatial_relation(self, objA, objB):
#         Ax, Ay, Aw, Ah = objA['bbox']
#         Bx, By, Bw, Bh = objB['bbox']
#
#         cxA, cyA = self.get_center(objA['bbox'])
#         cxB, cyB = self.get_center(objB['bbox'])
#
#         dx = cxB - cxA
#         dy = cyB - cyA
#         distance = math.sqrt(dx**2 + dy**2)
#         depthA = self.get_depth_score(objA['bbox'])
#         depthB = self.get_depth_score(objB['bbox'])
#         overlap = self.compute_overlap_ratio(objA['bbox'], objB['bbox'])
#
#         # LEFT / RIGHT
#         if abs(dx) > max(Aw, Bw) * 0.25:
#             relation = "left_of" if dx > 0 else "right_of"
#         # ABOVE / BELOW
#         elif abs(dy) > max(Ah, Bh) * 0.25:
#             relation = "above" if dy > 0 else "below"
#         else:
#             relation = "unknown"
#
#         # IN FRONT OF / BEHIND (only if overlap >= threshold)
#         if overlap >= self.overlap_thresh:
#             if depthA + 0.05 < depthB:
#                 relation = "in_front_of"
#             elif depthA - 0.05 > depthB:
#                 relation = "behind"
#
#         # NEAR (very close objects)
#         if distance < self.near_thresh:
#             relation = "near"
#
#         return relation
#
#     def build_adjacency_matrix(self, objects):
#         """Build adjacency matrix with spatial relations."""
#         n = len(objects)
#         matrix = [['' for _ in range(n + 1)] for _ in range(n + 1)]
#         labels = [f"{obj['label']}_{i}" for i, obj in enumerate(objects)]
#
#         # Header
#         matrix[0][0] = ''
#         for i in range(n):
#             matrix[0][i + 1] = labels[i]
#             matrix[i + 1][0] = labels[i]
#
#         # Fill matrix
#         for i, objA in enumerate(objects):
#             for j, objB in enumerate(objects):
#                 if i == j:
#                     continue
#                 matrix[i + 1][j + 1] = self.get_spatial_relation(objA, objB)
#
#         return matrix
#
#     def detect_objects(self, image_path):
#         """Detect objects using YOLO model."""
#         results = self.model.predict(image_path, show=False)
#         detected = []
#         for i, box in enumerate(results[0].boxes):
#             cls_id = int(box.cls[0].item())
#             label = results[0].names[cls_id]
#             x_center, y_center, w, h = box.xywh[0].tolist()
#             x_min = int(x_center - w / 2)
#             y_min = int(y_center - h / 2)
#             detected.append({'label': label, 'bbox': [x_min, y_min, int(w), int(h)]})
#         return detected
#
#
# # ===================== Example Usage =====================
# if __name__ == "__main__":
#     image_path = "C:\\Users\\PC\\Downloads\\p1.jpg"
#     model_path = "yolov8n.pt"
#
#     scene_handler = SceneGraphHandler(model_path)
#     objects = scene_handler.detect_objects(image_path)
#
#     for i, objA in enumerate(objects):
#         for j, objB in enumerate(objects):
#             if i != j:
#                 relation = scene_handler.get_spatial_relation(objA, objB)
#                 print(f"{objA['label']} -> {objB['label']}: {relation}")
#
#     matrix = scene_handler.build_adjacency_matrix(objects)
#     print("\nAdjacency Matrix:")
#     for row in matrix:
#         print(row)


#...........CODE GENERATOR.....................
# 'D:\PyCharm Project\\NS_VQA\ questions_template.txt'
# import json
# import re
# import csv
# import os
# import glob
#
#
# def get_indefinite_article(word):
#     """Returns 'a' or 'an' based on the first letter of the word."""
#     if not word: return 'a'
#     return 'an' if word[0].lower() in 'aeiou' else 'a'
#
#
# def process_question(template, obj_name):
#     """
#     Replaces 'an object'/'a object' with 'a/an {obj_name}'
#     and 'object' with '{obj_name}' in the template.
#     """
#     pattern_article = r'\b(an?)\s+object\b'
#
#     def replace_article(match):
#         original_article = match.group(1)
#         new_article = get_indefinite_article(obj_name)
#         if original_article and original_article[0].isupper():
#             new_article = new_article.capitalize()
#         return f"{new_article} {obj_name}"
#
#     text = re.sub(pattern_article, replace_article, template, flags=re.IGNORECASE)
#     # Replace "object" OR "obejct" (user typo) with the actual object name
#     text = re.sub(r'\b(obejct|object)\b', obj_name, text, flags=re.IGNORECASE)
#     # Clean up double spaces if any
#     return re.sub(r'\s+', ' ', text).strip()
#
#
# def get_relation(question_template):
#     """
#     Infers the relation type from the original question template.
#     """
#     q = question_template.lower()
#
#     # Order matters slightly for overlapping keywords
#     if any(x in q for x in
#            ['manufacturer', 'maker', 'brand', 'company', 'produce', 'factory', 'create', 'build', 'assembler']):
#         return 'manufacturer'
#     if any(x in q for x in ['material', 'made of', 'substance', 'composition', 'component material']):
#         return 'material used'
#     if any(x in q for x in ['color', 'colour', 'hue', 'shade', 'paint']):
#         return 'color'
#     if any(x in q for x in ['weigh', 'mass', 'heavy', 'load']):
#         return 'weight'
#     if any(x in q for x in ['height', 'tall', 'vertical', 'high']):
#         return 'height'
#     if any(x in q for x in ['lifespan', 'life', 'last', 'duration', 'longevity']):
#         return 'lifespan'
#
#     # Subclass logic
#     if any(x in q for x in ['subclass', 'category', 'class', 'type', 'kind', 'group', 'family', 'taxonomy']):
#         return 'subclass of'
#     # Fallback for generic "What is an object?"
#     if q.strip() in ['what is an object?', 'what is a obejct?', 'what is obejct?', 'what is an object',
#                      'define an object?']:
#         return 'subclass of'
#
#     # Part of vs Has part
#     # "part of" usually strictly matches "part of" or "belong to"
#     if 'part of' in q or 'belong to' in q or 'included in' in q:
#         return 'part of'
#
#     if any(x in q for x in ['part', 'component', 'consist', 'contain', 'include', 'make up', 'element']):
#         # If it wasn't caught by "part of" above, it's likely "has part"
#         return 'has part'
#
#     # Used for (broadest category, check last)
#     if any(x in q for x in
#            ['used for', 'purpose', 'function', 'serve', 'do', 'apply', 'application', 'usage', 'role', 'benefit']):
#         return 'used for'
#
#     return 'unknown'
#
#
# def get_object_name_from_file(file_path):
#     try:
#         with open(file_path, 'r', encoding='utf-8') as f:
#             data = json.load(f)
#             if isinstance(data, dict):
#                 for key in ['name', 'label', 'class', 'title', 'object']:
#                     if key in data and isinstance(data[key], str):
#                         return data[key]
#     except Exception as e:
#         print(f"Warning: Could not read JSON content from {os.path.basename(file_path)}: {e}")
#
#     filename = os.path.splitext(os.path.basename(file_path))[0]
#     return filename.replace('_', ' ').replace('-', ' ')
#
#
# def main():
#     # --- CONFIGURATION ---
#     input_folder = 'KnowledgeGraphs'
#     # Using the path provided by user, but defaulting to local if fails
#     questions_file_path = r'D:\PyCharm Project\NS_VQA\ questions_template.txt'
#     if not os.path.exists(questions_file_path):
#         questions_file_path = 'questions_template.txt'
#
#     output_file = 'dataset.csv'
#     # ---------------------
#
#     print("--- Object Question Dataset Generator ---")
#
#     if not os.path.exists(input_folder):
#         print(f"Error: Directory '{input_folder}' not found.")
#         # Create placeholder for demo
#         os.makedirs(input_folder, exist_ok=True)
#         with open(os.path.join(input_folder, 'aeroplane.json'), 'w') as f:
#             json.dump({"name": "aeroplane"}, f)
#
#     json_files = glob.glob(os.path.join(input_folder, '*.json'))
#
#     if not json_files:
#         print(f"No .json files found in '{input_folder}'.")
#         return
#
#     print(f"Found {len(json_files)} JSON files.")
#
#     if not os.path.exists(questions_file_path):
#         print(f"Error: '{questions_file_path}' not found.")
#         return
#
#     with open(questions_file_path, 'r', encoding='utf-8') as f:
#         questions = [line.strip() for line in f if line.strip()]
#
#     print(f"Loaded {len(questions)} question templates.")
#
#     total_objects = 0
#     total_rows = 0
#
#     with open(output_file, 'w', newline='', encoding='utf-8') as f_out:
#         writer = csv.writer(f_out)
#         # Updated Header
#         writer.writerow(['question', 'relation'])
#
#         for file_path in json_files:
#             obj_name = get_object_name_from_file(file_path)
#
#             if not obj_name:
#                 continue
#
#             for line in questions:
#                 # Support "Question|Relation" format
#                 parts = line.split('|')
#                 q_template = parts[0].strip()
#
#                 # Use explicit relation if available, otherwise infer
#                 if len(parts) > 1:
#                     relation = parts[1].strip()
#                 else:
#                     relation = get_relation(q_template)
#
#                 final_q = process_question(q_template, obj_name)
#
#                 writer.writerow([final_q, relation])
#                 total_rows += 1
#
#             total_objects += 1
#
#     print(f"Success! Processed {total_objects} objects.")
#     print(f"Generated {total_rows} rows in '{output_file}'.")
#     print(f"Check '{os.path.abspath(output_file)}'.")
#
#
# if __name__ == "__main__":
#     main()


#......Fixed CFG....................
# import os
# import json
# import sys
# import pyttsx3
#
# # Try importing pyttsx3, handle if missing
# try:
#     import pyttsx3
#
#     TTS_AVAILABLE = True
# except ImportError:
#     TTS_AVAILABLE = False
#     print("Warning: 'pyttsx3' not found. Speech output will be disabled.")
#
# # Try importing NLTK
# try:
#     import nltk
#     from nltk import CFG
# except ImportError:
#     print("Error: 'nltk' library is required. Please install it via 'pip install nltk'.")
#     sys.exit(1)
#
#
# # -------------------------
# # TEXT TO SPEECH
# # -------------------------
# def speak(text):
#     if not TTS_AVAILABLE:
#         return
#     try:
#         engine = pyttsx3.init()
#         # Voice selection (optional, stick to default if risky)
#         # engine.setProperty("rate", 160)
#         engine.say(text)
#         engine.runAndWait()
#         engine.stop()
#     except Exception as e:
#         print(f"[TTS Error]: {e}")
#
#
# # -------------------------
# # LOAD KNOWLEDGE GRAPH
# # -------------------------
# # Use a relative path or check current directory
# KG_FOLDER = os.path.join(os.getcwd(), "KnowledgeGraphs")
#
#
# def load_kg(folder_path):
#     kg = {}
#     if not os.path.exists(folder_path):
#         print(f"Error: Folder '{folder_path}' does not exist.")
#         return kg
#
#     print(f"Loading Knowledge Graphs from: {folder_path}")
#
#     for file in os.listdir(folder_path):
#         if file.lower().endswith(".json"):
#             file_path = os.path.join(folder_path, file)
#             try:
#                 with open(file_path, "r", encoding="utf-8") as f:
#                     data = json.load(f)
#
#                 # Check expected structure
#                 if "object" not in data or "triplets" not in data:
#                     print(f"Skipping {file}: Missing 'object' or 'triplets' keys.")
#                     continue
#
#                 obj = data["object"].lower()  # Lowercase for consistency
#                 kg[obj] = {}
#
#                 for triplet in data["triplets"]:
#                     if len(triplet) < 3: continue
#                     subj, relation, value = triplet
#                     # Store lowercased key for lookup, but value as is
#                     kg[obj].setdefault(relation.lower(), []).append(value)
#
#             except Exception as e:
#                 print(f"Error reading {file}: {e}")
#
#     return kg
#
#
# kg = load_kg(KG_FOLDER)
#
# # -------------------------
# # OBJECT LIST (lowercased for CFG)
# # -------------------------
# OBJECTS = list(kg.keys())
#
# if not OBJECTS:
#     print("Warning: No objects loaded. Please ensure JSON files are in 'KnowledgeGraphs'.")
#     # Add dummy object to prevent grammar crash
#     OBJECTS = ["dummy_object"]
#
# # -------------------------
# # RELATION MAPPING
# # Map Grammar Label -> Knowledge Graph Relation Key
# # -------------------------
# RELATION_MAP = {
#     "UsedForQ": "used for",
#     "HasPartQ": "has part",
#     "PartOfQ": "part of",
#     "MaterialQ": "material used",
#     "SubclassQ": "subclass of",
#     "LifespanQ": "lifespan",
#     "WeightQ": "weight",
#     "HeightQ": "height",
#     "ManufacturerQ": "manufacturer",
#     "ColorQ": "color"
# }
#
# # -------------------------
# # RELATION → NATURAL ANSWER TEMPLATE
# # -------------------------
# RELATION_TEMPLATES = {
#     "used for": "{object} is used for {value}.",
#     "has part": "{object} consists of {value}.",
#     "part of": "{object} is part of {value}.",
#     "material used": "{object} is made from {value}.",
#     "subclass of": "{object} belongs to {value}.",
#     "lifespan": "{object} typically lasts {value}.",
#     "weight": "{object} weighs around {value}.",
#     "height": "{object} has a height of {value}.",
#     "color": "{object} is available in {value}.",
#     "manufacturer": "{object} is manufactured by {value}."
# }
#
#
# # -------------------------
# # CFG Grammar (dynamic objects)
# # -------------------------
# # Helper to format multi-word objects for Grammar: "traffic" "light"
# def format_obj_for_grammar(obj_name):
#     parts = obj_name.split()
#     return " ".join(f'"{p}"' for p in parts)
#
#
# object_rules = " | ".join(format_obj_for_grammar(obj) for obj in OBJECTS)
#
# grammar_string = f"""
# S -> SubclassQ | PartOfQ | UsedForQ | HasPartQ | LifespanQ | HeightQ | WeightQ | ManufacturerQ | ColorQ
#
# Det -> "a" | "an" | "the"
#
# SubclassQ -> "what" "is" Det Object "?" | "define" Det Object "?" | "what" "type" "of" "object" "is" Det Object "?"
# PartOfQ -> "which" "system" "does" Det Object "belong" "to" "?" | Det Object "is" "part" "of" "?"
# UsedForQ -> "what" "is" "the" "purpose" "of" Det Object "?" | "what" "does" Det Object "do" "?"
# HasPartQ -> "what" "parts" "does" Det Object "have" "?" | "what" "components" "make" "up" Det Object "?"
# LifespanQ -> "how" "long" "does" Det Object "last" "?" | "expected" "life" "of" Det Object "?"
# HeightQ -> "how" "tall" "is" Det Object "?" | "tell" "me" "the" "height" "of" Det Object "?"
# WeightQ -> "how" "heavy" "is" Det Object "?" | "how" "much" "does" Det Object "weigh" "?"
# ManufacturerQ -> "who" "manufactures" Det Object "?" | "who" "makes" Det Object "?" | "who" "manufactured" Det Object "?"
# ColorQ -> "what" "color" "is" Det Object "?" | "what" "is" "the" "color" "of" Det Object "?" | "what" "colors" "does" Det Object "come" "in" "?"
#
# Object -> {object_rules}
# """
#
# try:
#     grammar = CFG.fromstring(grammar_string)
#     parser = nltk.ChartParser(grammar)
# except ValueError as e:
#     print(f"Grammar Error: {e}")
#     parser = None
#
#
# # -------------------------
# # CFG-Based Relation & Object Detection
# # -------------------------
# def classify_cfg(question):
#     if not parser: return None, None
#
#     # Preprocessing: simple logic to handle punctuation separately
#     # "car?" -> "car ?"
#     cleaned_q = question.lower().replace("?", " ?").replace(".", "")
#     words = cleaned_q.split()
#
#     try:
#         # parser.parse returns a generator of trees
#         for tree in parser.parse(words):
#             # The first child of S is the Question Type (e.g. LifespanQ)
#             rule_label = tree[0].label()
#
#             # Map rule label to KG relation
#             relation = RELATION_MAP.get(rule_label)
#
#             # Extract object from the subtree labeled 'Object'
#             found_object_tokens = []
#             for subtree in tree.subtrees(lambda t: t.label() == "Object"):
#                 # Collect all leaves (words) of the Object subtree
#                 found_object_tokens = subtree.leaves()
#                 break  # Assume one object per question
#
#             obj_str = " ".join(found_object_tokens)
#
#             return obj_str, relation
#
#         return None, None
#     except ValueError:
#         # Often happens if words are not in grammar (e.g., unknown words)
#         return None, None
#
#
# # -------------------------
# # ANSWER EXTRACTION
# # -------------------------
# def answer_question(question):
#     obj, relation = classify_cfg(question)
#
#     if not relation:
#         return "Sorry, I could not understand this specific question phrasing or the words used."
#
#     if not obj:
#         return "Sorry, I identified the question type but couldn't find the object."
#
#     # Look up object in KG
#     if obj not in kg:
#         return f"I understood you asked about '{obj}', but I have no data for it."
#
#     if relation not in kg[obj]:
#         return f"I have data for '{obj}' but no information about its '{relation}'."
#
#     values = kg[obj][relation]
#     # 'values' is a list of strings
#     value_text = ", ".join(values)
#
#     template = RELATION_TEMPLATES.get(
#         relation, "{object} {relation}: {value}"
#     )
#
#     # Capitalize first letter of object for the answer
#     obj_display = obj.capitalize()
#
#     return template.format(
#         object=obj_display,
#         relation=relation,
#         value=value_text
#     )
#
#
# # -------------------------
# # INTERACTIVE TEST
# # -------------------------
# def main():
#     print("\n=== CFG-Based KG QA System (Fixed) ===")
#     print(f"Loaded {len(OBJECTS)} objects: {', '.join(OBJECTS[:5])}...")
#     print("Ask a question (type 'exit' to quit). Try:")
#     if OBJECTS:
#         sample_obj = OBJECTS[0]
#         print(f" - What is the purpose of a {sample_obj}?")
#         print(f" - How much does a {sample_obj} weigh?")
#     print("-" * 40)
#
#     while True:
#         try:
#             q = input("Your question: ")
#         except EOFError:
#             break
#
#         if q.lower() in ["exit", "quit"]:
#             break
#
#         if not q.strip(): continue
#
#         answer = answer_question(q)
#         print("Answer:", answer)
#         speak(answer)
#
#
# if __name__ == "__main__":
#     main()



#.......Imp Questions............
# "SubclassQ": [
#         "What is a {obj}?",
#         "Define a {obj}?",
#         "What type of object is a {obj}?"
#     ],
#
#     "UsedForQ": [
#         "What is the purpose of a {obj}?",
#         "What does a {obj} do?"
#     ],
#
#     "HasPartQ": [
#         "What parts does a {obj} have?",
#         "What components make up a {obj}?"
#     ],
#
#     "PartOfQ": [
#         "Which system does a {obj} belong to?",
#         "A {obj} is part of?"
#     ],
#
#     "LifespanQ": [
#         "How long does a {obj} last?",
#         "Expected life of a {obj}?"
#     ],
#
#     "HeightQ": [
#         "How tall is a {obj}?",
#         "Tell me the height of a {obj}?"
#     ],
#
#     "WeightQ": [
#         "How heavy is a {obj}?",
#         "How much does a {obj} weigh?"
#     ],
#
#     "ManufacturerQ": [
#         "Who manufactures a {obj}?",
#         "Who makes a {obj}?",
#         "Who manufactured a {obj}?"
#     ],
#
#     "ColorQ": [
#         "What color is a {obj}?",
#         "What is the color of a {obj}?",
#         "What colors does a {obj} come in?"
#     ]



# #...........Fixed REGEX......................
# import os
# import json
# import sys
# import re
#
# # Try importing pyttsx3, handle if missing
# try:
#     import pyttsx3
#
#     TTS_AVAILABLE = True
# except ImportError:
#     TTS_AVAILABLE = False
#     print("Warning: 'pyttsx3' not found. Speech output will be disabled.")
#
#
# # -------------------------
# # TEXT TO SPEECH
# # -------------------------
# def speak(text):
#     if not TTS_AVAILABLE:
#         return
#     try:
#         engine = pyttsx3.init()
#         # Voice selection (optional)
#         # engine.setProperty("rate", 160)
#         engine.say(text)
#         engine.runAndWait()
#         engine.stop()
#     except Exception as e:
#         print(f"[TTS Error]: {e}")
#
#
# # -------------------------
# # LOAD KNOWLEDGE GRAPH
# # -------------------------
# KG_FOLDER = os.path.join(os.getcwd(), "KnowledgeGraphs")
#
#
# def load_kg(folder_path):
#     kg = {}
#     if not os.path.exists(folder_path):
#         print(f"Error: Folder '{folder_path}' does not exist.")
#         return kg
#
#     print(f"Loading Knowledge Graphs from: {folder_path}")
#
#     for file in os.listdir(folder_path):
#         if file.lower().endswith(".json"):
#             file_path = os.path.join(folder_path, file)
#             try:
#                 with open(file_path, "r", encoding="utf-8") as f:
#                     data = json.load(f)
#
#                 if "object" not in data or "triplets" not in data:
#                     print(f"Skipping {file}: Missing 'object' or 'triplets' keys.")
#                     continue
#
#                 obj = data["object"].lower()
#                 kg[obj] = {}
#
#                 for triplet in data["triplets"]:
#                     if len(triplet) < 3: continue
#                     subj, relation, value = triplet
#                     kg[obj].setdefault(relation.lower(), []).append(value)
#
#             except Exception as e:
#                 print(f"Error reading {file}: {e}")
#
#     return kg
#
#
# kg = load_kg(KG_FOLDER)
#
# # -------------------------
# # OBJECT LIST
# # -------------------------
# # Sort objects by length (descending) to match longest names first (e.g. "traffic light" before "traffic")
# OBJECTS = sorted(list(kg.keys()), key=len, reverse=True)
#
# if not OBJECTS:
#     print("Warning: No objects loaded. Please ensure JSON files are in 'KnowledgeGraphs'.")
#     OBJECTS = ["dummy_object"]
#
# # -------------------------
# # RELATION PATTERNS (REGEX)
# # -------------------------
# # Mapping Regex Patterns -> Knowledge Graph Relation Key
# RELATION_PATTERNS = {
#     "manufacturer": [
#         r"who\s+manufactures", r"who\s+makes", r"who\s+produced", r"manufacturer", r"brand", r"company", r"maker"
#     ],
#     "material used": [
#         r"material", r"made\s+of", r"made\s+from", r"consist\s+of", r"substance", r"composition"
#     ],
#     "color": [
#         r"color", r"colour", r"hue", r"shade", r"paint"
#     ],
#     "weight": [
#         r"weight", r"weigh", r"heavy", r"mass"
#     ],
#     "height": [
#         r"height", r"tall", r"high"
#     ],
#     "lifespan": [
#         r"lifespan", r"life\s+expectancy", r"how\s+long\s+.*last", r"duration", r"longevity"
#     ],
#     "subclass of": [
#         r"subclass", r"category", r"type\s+of", r"kind\s+of", r"classification", r"define",
#         r"what\s+is\s+(a|an|the)?\s*<OBJECT>\??$"
#     ],
#     "part of": [
#         r"part\s+of", r"belong\s+to", r"included\s+in"
#     ],
#     "has part": [
#         r"has\s+part", r"consist\s+of", r"contain", r"composed\s+of", r"include", r"components", r"parts"
#     ],
#     "used for": [
#         r"used\s+for", r"purpose", r"function", r"use", r"do\s+with", r"apply"
#     ]
# }
#
# # -------------------------
# # ANSWER TEMPLATES
# # -------------------------
# RELATION_TEMPLATES = {
#     "used for": "{object} is used for {value}.",
#     "has part": "{object} consists of {value}.",
#     "part of": "{object} is part of {value}.",
#     "material used": "{object} is made from {value}.",
#     "subclass of": "{object} belongs to {value}.",
#     "lifespan": "{object} typically lasts {value}.",
#     "weight": "{object} weighs around {value}.",
#     "height": "{object} has a height of {value}.",
#     "color": "{object} is available in {value}.",
#     "manufacturer": "{object} is manufactured by {value}."
# }
#
#
# # -------------------------
# # REGEX-BASED CLASSIFICATION
# # -------------------------
# def classify_regex(question):
#     q_lower = question.lower().strip()
#
#     # 1. Identify Object
#     found_obj = None
#     for obj in OBJECTS:
#         # Check if object name appears in the question as a whole word
#         # Using regex word boundaries \b
#         if re.search(r'\b' + re.escape(obj) + r'\b', q_lower):
#             found_obj = obj
#             break
#
#     if not found_obj:
#         return None, None
#
#     # 2. Identify Relation
#     # Replace the object in the question with <OBJECT> to help subclass pattern matching
#     # e.g. "What is a car?" -> "What is a <OBJECT>?"
#     q_masked = re.sub(r'\b' + re.escape(found_obj) + r'\b', '<OBJECT>', q_lower)
#
#     found_relation = None
#
#     # Check "subclass of" specific strict pattern first ("What is X?")
#     # This prevents "What is X used for?" from being matched as "subclass"
#     if re.search(r"^what\s+is\s+(a|an|the)?\s*<OBJECT>\??$", q_masked):
#         return found_obj, "subclass of"
#
#     # Iterate through patterns
#     for relation, patterns in RELATION_PATTERNS.items():
#         for pattern in patterns:
#             if re.search(pattern, q_masked):
#                 found_relation = relation
#                 break
#         if found_relation:
#             break
#
#     # Default fallback for "What is X?" if missed (though covered above)
#     if not found_relation and "what is" in q_lower:
#         found_relation = "subclass of"
#
#     return found_obj, found_relation
#
#
# # -------------------------
# # ANSWER EXTRACTION
# # -------------------------
# def answer_question(question):
#     obj, relation = classify_regex(question)
#
#     if not obj:
#         return "Sorry, I identified the question type but couldn't find the object."
#
#     if not relation:
#         return "Sorry, I could not understand the type of question."
#
#     # Look up object in KG
#     if obj not in kg:
#         return f"I understood you asked about '{obj}', but I have no data for it."
#
#     if relation not in kg[obj]:
#         return f"I have data for '{obj}' but no information about its '{relation}'."
#
#     values = kg[obj][relation]
#     value_text = ", ".join(values)
#
#     template = RELATION_TEMPLATES.get(
#         relation, "{object} {relation}: {value}"
#     )
#
#     obj_display = obj.capitalize()
#
#     return template.format(
#         object=obj_display,
#         relation=relation,
#         value=value_text
#     )
#
#
# # -------------------------
# # MAIN INTERACTIVE LOOP
# # -------------------------
# def main():
#     print("\n=== Regex-Based KG QA System ===")
#     print(f"Loaded {len(OBJECTS)} objects.")
#     print("Example questions:")
#     print(" - What is an air conditioner?")
#     print(" - Who makes the car?")
#     print("-" * 40)
#
#     while True:
#         try:
#             q = input("Your question: ")
#         except EOFError:
#             break
#
#         if q.lower() in ["exit", "quit"]:
#             break
#
#         if not q.strip(): continue
#
#         answer = answer_question(q)
#         print("Answer:", answer)
#         speak(answer)
#
#
# if __name__ == "__main__":
#     main()
#.............


# import joblib
# clf = joblib.load(r"D:\PyCharm Project\NS_VQA\modelsNSVQA\relation_classifier_fahad.pkl")
# vect = joblib.load(r"D:\PyCharm Project\NS_VQA\modelsNSVQA\vectorizer_fahad.pkl")
# print(clf)
# print(vect)


# import math
# import numpy as np
#
# try:
#     from ultralytics import YOLO
#
#     YOLO_AVAILABLE = True
# except ImportError:
#     YOLO_AVAILABLE = False
#     print("Warning: 'ultralytics' module not found. Object detection will not work, but logic is accessible.")
#
#
# class SceneGraphHandler:
#     def __init__(self, model_path=None, image_height=720, image_width=1280, near_thresh=200, overlap_thresh=0.1):
#         if model_path and YOLO_AVAILABLE:
#             self.model = YOLO(model_path)
#         else:
#             self.model = None
#
#         self.image_height = image_height
#         self.image_width = image_width
#         self.near_thresh = near_thresh
#         self.overlap_thresh = overlap_thresh
#
#     def get_bbox_center(self, bbox):
#         x, y, w, h = bbox
#         return x + w / 2, y + h / 2
#
#     def get_depth_score_feature(self, bbox):
#         """
#         Simple depth heuristic: Lower Y-bottom = Closer to camera.
#         Returns the y-coordinate of the bottom edge.
#         Higher value = Closer (since Y increases downwards).
#         """
#         x, y, w, h = bbox
#         return y + h
#
#     def compute_iou(self, boxA, boxB):
#         Ax1, Ay1, Aw, Ah = boxA
#         Ax2, Ay2 = Ax1 + Aw, Ay1 + Ah
#         Bx1, By1, Bw, Bh = boxB
#         Bx2, By2 = Bx1 + Bw, By1 + Bh
#
#         xA = max(Ax1, Bx1)
#         yA = max(Ay1, By1)
#         xB = min(Ax2, Bx2)
#         yB = min(Ay2, By2)
#
#         interWidth = max(0, xB - xA)
#         interHeight = max(0, yB - yA)
#         interArea = interWidth * interHeight
#
#         areaA = Aw * Ah
#         areaB = Bw * Bh
#
#         iou = interArea / float(areaA + areaB - interArea + 1e-6)
#         return iou
#
#     def get_euclidean_distance(self, bbox1, bbox2):
#         cx1, cy1 = self.get_bbox_center(bbox1)
#         cx2, cy2 = self.get_bbox_center(bbox2)
#         return math.sqrt((cx1 - cx2) ** 2 + (cy1 - cy2) ** 2)
#
#     def get_relation(self, obj1, obj2):
#         box1 = obj1['bbox']
#         box2 = obj2['bbox']
#
#         iou = self.compute_iou(box1, box2)
#         dist = self.get_euclidean_distance(box1, box2)
#
#         cx1, cy1 = self.get_bbox_center(box1)
#         cx2, cy2 = self.get_bbox_center(box2)
#
#         # Dimensions
#         w1, h1 = box1[2], box1[3]
#         w2, h2 = box2[2], box2[3]
#
#         # Top/Bottom edges
#         top1, bottom1 = box1[1], box1[1] + h1
#         top2, bottom2 = box2[1], box2[1] + h2
#
#         # Directional Deltas
#         dx = cx2 - cx1  # Positive if obj2 is Right
#         dy = cy2 - cy1  # Positive if obj2 is Down (Below)
#
#         # ---------------------------------------------------------
#         # 1. CHECK "ON" (Vertical Support)
#         # ---------------------------------------------------------
#         # Obj1 (Top) ON Obj2 (Bottom)
#         # Conditions:
#         # - Physically above: cy1 < cy2
#         # - Good horizontal alignment
#         # - Vertical proximity: bottom of 1 is near top of 2
#         # REFINEMENT: Allow some overlap (perspective often places cup slightly 'inside' table box)
#
#         x_overlap = min(box1[0] + w1, box2[0] + w2) - max(box1[0], box2[0])
#         horizontal_overlap_ratio = x_overlap / float(min(w1, w2) + 1e-6)
#
#         # Check if obj1 is smaller (support logic)
#         is_smaller = (w1 * h1) < (w2 * h2) * 0.8
#
#         if horizontal_overlap_ratio > 0.3 and cy1 < cy2:
#             # Vertical Check:
#             # Bottom1 should be close to Top2 OR inside the top region of Box2
#             gap = top2 - bottom1
#             # "On" usually means bottom1 is >= top2 (gap <= 0) but not too deep
#             # Allow bottom1 to sink into obj2 up to 30% of obj2's height (perspective)
#             # Allow bottom1 to float above obj2 up to 10% of obj2's height
#             if -h2 * 0.4 < gap < h2 * 0.1:  # or bottom1 is roughly at top2
#                 return "on"
#             # Support case: sitting strictly inside the bounding box but at the top
#             if bottom1 > top2 and bottom1 < top2 + (h2 * 0.5):
#                 # Stronger check: is it smaller?
#                 if is_smaller:
#                     return "on"
#
#         # ---------------------------------------------------------
#         # 2. CHECK "IN FRONT OF" / "BEHIND" (Partial Occlusion)
#         # ---------------------------------------------------------
#         # If overlapping significantly
#         if iou > self.overlap_thresh:
#             y_bottom1 = self.get_depth_score_feature(box1)
#             y_bottom2 = self.get_depth_score_feature(box2)
#
#             # Whichever bottom is lower (higher Y) is clearly in front
#             diff = y_bottom1 - y_bottom2
#
#             # Threshold: must be significantly lower (e.g., 5% of img height or simple pixel relative)
#             # Normalizing by object height helps robustness
#             avg_h = (h1 + h2) / 2
#
#             if diff > avg_h * 0.1:
#                 return "in_front_of"
#             elif diff < -avg_h * 0.1:
#                 return "behind"
#
#         # ---------------------------------------------------------
#         # 3. CHECK "NEAR"
#         # ---------------------------------------------------------
#         # Distance-based, if not overlapping much
#         if dist < self.near_thresh:
#             return "near"
#
#         # ---------------------------------------------------------
#         # 4. DIRECTIONAL (Fallback)
#         # ---------------------------------------------------------
#         # If mainly horizontal difference
#         if abs(dx) > abs(dy):
#             return "left_of" if dx > 0 else "right_of"
#         else:
#             return "above" if dy > 0 else "below"
#
#     def build_adjacency_matrix(self, objects):
#         """
#         Builds a matrix where M[i][j] is the relation from object i to object j.
#         """
#         n = len(objects)
#         labels = [obj['label'] for obj in objects]
#
#         matrix = [[None] * (n + 1) for _ in range(n + 1)]
#         matrix[0][0] = ""
#         for i in range(n):
#             matrix[0][i + 1] = labels[i]
#             matrix[i + 1][0] = labels[i]
#
#         for i in range(n):
#             for j in range(n):
#                 if i == j:
#                     matrix[i + 1][j + 1] = "self"
#                     continue
#
#                 rel = self.get_relation(objects[i], objects[j])
#                 matrix[i + 1][j + 1] = rel
#
#         return matrix
#
#     def detect_objects(self, image_path):
#         if not self.model:
#             print("Model not loaded.")
#             return []
#
#         results = self.model.predict(image_path, show=False)
#         boxes = results[0].boxes
#
#         detected = []
#         for box in boxes:
#             cls_id = int(box.cls[0].item())
#             label = results[0].names[cls_id]
#
#             x_c, y_c, w, h = box.xywh[0].tolist()
#             x = int(x_c - w / 2)
#             y = int(y_c - h / 2)
#
#             detected.append({
#                 "label": label,
#                 "bbox": [x, y, int(w), int(h)],
#                 "confidence": float(box.conf[0].item())
#             })
#
#         return detected
#
# # ===================== Test =====================
# if __name__ == "__main__":
#     model_path = r"D:\PyCharm Project\NS_VQA\modelsNSVQA\last.pt"
#     image_path = r"C:\Users\PC\Downloads\amb.jpeg"
#
#     handler = SceneGraphHandler(
#         model_path=model_path,
#         image_height=720,
#         image_width=1280
#     )
#
#     objects = handler.detect_objects(image_path)
#
#     print("\nDetected Objects:")
#     for obj in objects:
#         print(obj)
#
#     print("\nRelations:")
#     for i, obj1 in enumerate(objects):
#         for j, obj2 in enumerate(objects):
#             if i != j:
#                 rel = handler.get_relation(obj1, obj2)
#                 print(f"{obj1['label']} -> {obj2['label']} : {rel}")
#
#     print("\nAdjacency Matrix:")
#     matrix = handler.build_adjacency_matrix(objects)
#     for row in matrix:
#         print(row)



# from ultralytics import YOLO
# from deepface import DeepFace
# import cv2
# import os
# import tempfile
#
# # ----------------- PATHS -----------------
# yolo_model_path = r"D:\PyCharm Project\NS_VQA\modelsNSVQA\last.pt"
# group_image_path = r"C:\Users\PC\Downloads\khan.jpg"
# known_faces_dir = r"D:\PyCharm Project\NS_VQA\faces"
#
# # ----------------- LOAD MODELS -----------------
# yolo = YOLO(yolo_model_path)
#
# image = cv2.imread(group_image_path)
# if image is None:
#     raise Exception("Group image not found")
#
# # ----------------- YOLO DETECTION -----------------
# results = yolo.predict(source=group_image_path)
#
# person_found = False
#
# for result in results:
#     for box in result.boxes:
#         cls = int(box.cls[0])
#         if cls != 0:  # only PERSON
#             continue
#
#         # Bounding box
#         x1, y1, x2, y2 = map(int, box.xyxy[0])
#         w = x2 - x1
#         h = y2 - y1
#
#         # ----------------- FACE CROP RULES -----------------
#         top = y1
#         bottom = y1 + int(h * 0.6)       # 60% from top
#         margin = int(w * 0.15)           # 15% left/right
#         left = x1 + margin
#         right = x2 - margin
#
#         face_crop = image[top:bottom, left:right]
#
#         if face_crop.size == 0:
#             continue
#
#         # ----------------- TEMP IMAGE FOR DEEPFACE -----------------
#         with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as tmp:
#             temp_face_path = tmp.name
#             cv2.imwrite(temp_face_path, face_crop)
#
#         # ----------------- DEEPFACE SEARCH -----------------
#         try:
#             result_df = DeepFace.find(
#                 img_path=temp_face_path,
#                 db_path=known_faces_dir,
#                 enforce_detection=True,
#                 model_name="ArcFace"  # better accuracy
#             )
#
#             for df in result_df:
#                 if not df.empty:
#                     person_found = True
#                     break
#
#         except:
#             pass
#
#         os.remove(temp_face_path)
#
#         if person_found:
#             break
#
#     if person_found:
#         break
#
# # ----------------- FINAL RESULT -----------------
# if person_found:
#     print("✅ Known person IS PRESENT in the image")
# else:
#     print("❌ Known person is NOT present in the image")



from Controllers.SceneHandler import SceneHandler
import pprint

# Mock Data reflecting the user's scenario
objects = [
    "Person_0", "Person_1", "Chair_6", "Cabinet/shelf_7", "Desk_5"
]

# Note: The user said "in scene graph there are objects left of person"
# and provided snippet:
# {'from': 'Person_0', 'relation': 'right_of', 'to': 'Cabinet/shelf_7'}
# This implies Cabinet is left of Person.
# Also 'Person_0' 'left_of' 'Person_1' -> Person_1 is right of Person_0.
# Also 'Person_0' 'left_of' 'Chair_6' -> Chair is right of Person_0.

scene_graph = [
    {'from': 'Person_0', 'relation': 'left_of', 'to': 'Person_1'},
    {'from': 'Person_0', 'relation': 'right_of', 'to': 'Cabinet/shelf_7'},
    {'from': 'Person_0', 'relation': 'left_of', 'to': 'Desk_5'}, # Person is left of Desk -> Desk is right of Person
]

# We don't need real properties for this test
properties = [{} for _ in objects]

handler = SceneHandler(objects, scene_graph, properties)

print("--- Testing Relation Query ---")
question = "Is there anything left of Person?"
print(f"Question: {question}")
answer = handler.ask(question)
print(f"Answer: {answer}")

# Expected behavior based on user report:
# "No objects are left of Person." (Current Bug)

# Desired behavior:
# Should find Cabinet/shelf_7 because Person is right of Cabinet.
# (If Person is right of Cabinet, then Cabinet is left of Person)

