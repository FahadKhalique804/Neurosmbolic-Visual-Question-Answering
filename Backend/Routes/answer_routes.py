# from flask import Blueprint, request, jsonify
# from Controllers.AnswerHandler import AnswerHandler
# from Models.cfg_models import CFGModel
# from Controllers.ImageHandler import ImageHandler
# from Controllers.ObjectDetectionHandler import ObjectDetectionHandler
# from Controllers.PropertiesHandler import PropertyHandler
# from Controllers.SceneGraphConfigure import SceneGraphHandler
# from TestFiles.SceneHandler import SceneHandler  # Your custom SceneHandler
# import cv2
# from Models.BlindQuery_models import BlindHistoryModel
#
# import hashlib
# from datetime import datetime
# import os
# import logging
#
# answer_routes = Blueprint("answer_routes", __name__)
#
# # Handlers
# image_handler = ImageHandler()
# detector = ObjectDetectionHandler()
# property_handler = PropertyHandler()
# scene_builder = SceneGraphHandler()
# cfg_model = CFGModel()
# answer_handler = AnswerHandler(cfg_model)
#
# def get_image_hash(file_bytes):
#     return hashlib.md5(file_bytes).hexdigest()
#
# def process_image(file):
#     """
#     Process the image fresh every time it is uploaded.
#     Returns detections, properties, scene graph, and saved image path.
#     """
#     image_bytes = file.read()
#     file.seek(0)
#     image_hash = get_image_hash(image_bytes)
#
#     # Save image as .webp
#     image_path = image_handler.save_image(file, upload_dir="static/AnswerPics", convert_webp=True)
#     image = image_handler.load_image(image_path)
#
#     # Detect objects
#     detections = detector.detect_objects(image_path)
#     detections_with_props = property_handler.assign_properties(image, detections)
#
#     # Build scene graph matrix
#     scene_matrix = scene_builder.build_adjacency_matrix(detections_with_props)
#
#     # Convert scene_matrix to list of objects and relationships for SceneHandler
#     objects = [det['label'] for det in detections_with_props]
#     props_dict = {det['label']: det for det in detections_with_props}
#
#     relationships = []
#     for i in range(1, len(scene_matrix)):
#         src = scene_matrix[i][0]
#         for j in range(1, len(scene_matrix[i])):
#             rel = scene_matrix[i][j]
#             if rel:
#                 tgt = scene_matrix[0][j]
#                 relationships.append({
#                     "from": src,
#                     "to": tgt,
#                     "relation": rel
#                 })
#
#     # Then initialize SceneHandler
#     scene_handler = SceneHandler(objects, relationships, [props_dict[obj] for obj in objects])
#
#     # Draw bounding boxes for preview
#     for det in detections_with_props:
#         x, y, w, h = det['bbox']
#         label = det['label']
#         cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
#         cv2.putText(image, label, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 1)
#
#     preview_path = os.path.join("uploads", f"preview_{image_hash}.jpg")
#     cv2.imwrite(preview_path, image)
#
#     return {
#         "objects": objects,
#         "properties": detections_with_props,
#         "scene_graph": relationships,
#         "image_path": preview_path
#     }
#
# # ---------------- Flask route ----------------
# @answer_routes.route("/ask", methods=["POST"])
# def ask_question():
#     file = request.files.get("image")
#     question = request.form.get("question")
#
#     if not file or not question:
#         return jsonify({"error": "Image and question are required"}), 400
#
#     try:
#         # Process image and get scene info
#         result = process_image(file)
#         objects = result["objects"]
#         props = result["properties"]
#         scene_graph = result["scene_graph"]
#
#         # Initialize SceneHandler with fresh data
#         scene_handler = SceneHandler(objects, scene_graph, [props[obj] for obj in objects])
#
#         # Ask the question
#         answer = scene_handler.ask(question)
#
#         return jsonify({
#             "answer": answer,
#             "image_path": result["image_path"]
#         })
#
#     except Exception as e:
#         logging.exception("Error processing /ask request")
#         return jsonify({"error": "Something went wrong", "details": str(e)}), 500




# from flask import Blueprint, request, jsonify
# from Controllers.AnswerHandler import AnswerHandler
# from Models.cfg_models import CFGModel
# from Controllers.ImageHandler import ImageHandler
# from Controllers.ObjectDetectionHandler import ObjectDetectionHandler
# from Controllers.PropertiesHandler import PropertyHandler
# from Controllers.SceneGraphConfigure import SceneGraphHandler
# from TestFiles.SceneHandler import SceneHandler  # Your custom SceneHandler
# import cv2
# from Models.BlindQuery_models import BlindHistoryModel
#
# import hashlib
# from datetime import datetime
# import os
# import logging
#
# answer_routes = Blueprint("answer_routes", __name__)
#
# # ---------------- Handlers ----------------
# image_handler = ImageHandler()
# detector = ObjectDetectionHandler()
# property_handler = PropertyHandler()
# scene_builder = SceneGraphHandler()
# cfg_model = CFGModel()
# answer_handler = AnswerHandler(cfg_model)
#
# # ---------------- Helpers ----------------
# def get_image_hash(file_bytes):
#     return hashlib.md5(file_bytes).hexdigest()
#
# def process_image(file):
#     """
#     Process the image fresh every time.
#     Returns:
#         - objects: list of object labels
#         - properties: list of dicts for each object
#         - scene_graph: list of relationships
#         - image_path: saved preview image
#     """
#     image_bytes = file.read()
#     file.seek(0)
#     image_hash = get_image_hash(image_bytes)
#
#     # Save image
#     image_path = image_handler.save_image(file, upload_dir="static/AnswerPics", convert_webp=True)
#     image = image_handler.load_image(image_path)
#
#     # Detect objects
#     detections = detector.detect_objects(image_path)
#     detections_with_props = property_handler.assign_properties(image, detections)
#
#     # Build scene graph adjacency matrix
#     scene_matrix = scene_builder.build_adjacency_matrix(detections_with_props)
#
#     # Prepare objects list and relationships
#     objects = [det['label'] for det in detections_with_props]
#     props_dict = {det['label']: det for det in detections_with_props}
#
#     relationships = []
#     for i in range(1, len(scene_matrix)):
#         src = scene_matrix[i][0]
#         for j in range(1, len(scene_matrix[i])):
#             rel = scene_matrix[i][j]
#             if rel:
#                 tgt = scene_matrix[0][j]
#                 relationships.append({
#                     "from": src,
#                     "to": tgt,
#                     "relation": rel
#                 })
#
#     # Draw bounding boxes for preview
#     for det in detections_with_props:
#         x, y, w, h = det['bbox']
#         label = det['label']
#         cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
#         cv2.putText(image, label, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 1)
#
#     preview_path = os.path.join("uploads", f"preview_{image_hash}.jpg")
#     cv2.imwrite(preview_path, image)
#     return objects, [props_dict[obj] for obj in objects], relationships, preview_path
# #
# # # ---------------- Flask Route ----------------
# # @answer_routes.route("/getanswer/<int:blind_id>", methods=["POST"])
# # def ask_question(blind_id):
# #     file = request.files.get("image")
# #     question = request.form.get("question")
# #
# #     if not file or not question:
# #         return jsonify({"error": "Image and question are required"}), 400
# #
# #     try:
# #         # Process image and prepare SceneHandler
# #         objects, properties, scene_graph, image_path = process_image(file)
# #         print(objects)
# #         print(properties)
# #         print(scene_graph)
# #         scene_handler = SceneHandler(objects, scene_graph, properties)
# #
# #         # Get answer from SceneHandler
# #         answer = scene_handler.ask(question)
# #         if not answer:
# #             return jsonify({"error": "Could not generate a valid answer."}), 400
# #
# #             # Handle specific messages
# #         if answer in ["I can't find that object in the image.",
# #                       " This question does not match any known CFG template."]:
# #             return jsonify({"answer": answer})
# #
# #             # Save blind query history
# #         created_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
# #         BlindHistoryModel().create_query(question, answer, image_path,blind_id, created_at)
# #
# #         return jsonify({"answer": answer})
# #
# #
# #     except Exception as e:
# #         logging.exception("Error processing /ask request")
# #         return jsonify({"error": "Something went wrong", "details": str(e)}), 500
#
#
#
#
# @answer_routes.route("/getanswer/<int:blind_id>", methods=["POST"])
# def ask_question(blind_id):
#     file = request.files.get("image")
#     question = request.form.get("question")
#
#     if not file or not question:
#         return jsonify({"error": "Image and question are required"}), 400
#
#     try:
#         # Process image and prepare SceneHandler
#         objects, properties, scene_graph, image_path = process_image(file)
#
#         # Optional: print for debug
#         print(objects)
#         print(properties)
#         print(scene_graph)
#
#         scene_handler = SceneHandler(objects, scene_graph, properties)
#
#         # Get answer from SceneHandler
#         answer = scene_handler.ask(question)
#         if not answer:
#             return jsonify({"error": "Could not generate a valid answer."}), 400
#
#         # Prepare scene graph triplets for frontend
#         scene_triplets = [
#             {"from": rel["from"], "relation": rel["relation"], "to": rel["to"]}
#             for rel in scene_graph
#         ]
#
#         # Prepare detections for frontend
#         detections_list = []
#         for prop in properties:
#             detections_list.append({
#                 "label": prop.get("label", "unknown"),
#                 "bbox": prop.get("bbox", []),
#                 "color": prop.get("color", "unknown"),
#                 "shape": prop.get("shape", "unknown"),
#                 "emotion": prop.get("emotion", "not_applicable")
#             })
#
#         # Encode image as a URL path for frontend (already saved in process_image)
#         preview_image_url = "/" + image_path.replace("\\", "/")  # ensure forward slashes
#
#         # Save blind query history
#         created_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
#         BlindHistoryModel().create_query(question, answer, image_path, blind_id, created_at)
#
#         # Return all info as JSON
#         return jsonify({
#             "answer": answer,
#             "detections": detections_list,
#             "scene_graph": scene_triplets,
#             "image_url": preview_image_url
#         })
#
#     except Exception as e:
#         logging.exception("Error processing /ask request")
#         return jsonify({"error": "Something went wrong", "details": str(e)}), 500


# from flask import Blueprint, request, jsonify
# from Controllers.AnswerHandler import AnswerHandler
# from Models.cfg_models import CFGModel
# from Controllers.ImageHandler import ImageHandler
# from Controllers.ObjectDetectionHandler import ObjectDetectionHandler
# from Controllers.PropertiesHandler import PropertyHandler
# from Controllers.SceneGraphHandler import SceneGraphHandler
# from Controllers.SceneHandler import SceneHandler
# import cv2
# from Models.BlindHistory_models import BlindHistoryModel
#
# import hashlib
# from datetime import datetime
# import os
# import logging
# from Controllers.Answer_Engine import HybridKGBasedQA
# answer_routes = Blueprint("answer_routes", __name__)
#
# # ---------------- Handlers ----------------
# image_handler = ImageHandler()
# detector = ObjectDetectionHandler()
# property_handler = PropertyHandler()
# scene_builder = SceneGraphHandler()
# cfg_model = CFGModel()
# answer_handler = AnswerHandler(cfg_model)
# hybrid_qa=HybridKGBasedQA(r"D:\PyCharm Project\NS_VQA\Controllers\KnowledgeGraphs")
#
# # ---------------- Helpers ----------------
# def get_image_hash(file_bytes):
#     return hashlib.md5(file_bytes).hexdigest()
#
# def process_image(file):
#     """
#     Process the image fresh every time.
#     """
#     image_bytes = file.read()
#     file.seek(0)
#     image_hash = get_image_hash(image_bytes)
#
#     # Save the uploaded image
#     image_path = image_handler.save_image(file, upload_dir="static/AnswerPics", convert_webp=True)
#     image = image_handler.load_image(image_path)
#
#     # Detect objects
#     detections = detector.detect_objects(image_path)
#     detections_with_props = property_handler.assign_properties(image, detections)
#
#     # Build scene graph adjacency matrix
#     scene_matrix = scene_builder.build_adjacency_matrix(detections_with_props)
#
#     # Prepare objects + relationship list
#     objects = [det['label'] for det in detections_with_props]
#     props_dict = {det['label']: det for det in detections_with_props}
#
#     relationships = []
#     for i in range(1, len(scene_matrix)):
#         src = scene_matrix[i][0]
#         for j in range(1, len(scene_matrix[i])):
#             rel = scene_matrix[i][j]
#             if rel:
#                 tgt = scene_matrix[0][j]
#                 relationships.append({
#                     "from": src,
#                     "to": tgt,
#                     "relation": rel
#                 })
#
#     # ------------------------------
#     # SAVE PREVIEW IN static/answerreturned/
#     # ------------------------------
#     preview_dir = os.path.join("static", "answerreturned")
#     os.makedirs(preview_dir, exist_ok=True)
#
#     preview_filename = f"preview_{image_hash}.jpg"
#     preview_path = os.path.join(preview_dir, preview_filename)
#
#     # Draw bounding boxes
#     for det in detections_with_props:
#         x, y, w, h = det['bbox']
#         label = det['label']
#         cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
#         cv2.putText(image, label, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 1)
#
#     cv2.imwrite(preview_path, image)
#
#     # Return ONLY relative path (NO URL)
#     relative_preview_path = f"static/answerreturned/{preview_filename}"
#
#     return objects, [props_dict[obj] for obj in objects], relationships, relative_preview_path
#
#
#
# # ---------------- Flask Route ----------------
# @answer_routes.route("/getanswer/<int:blind_id>", methods=["POST"])
# def ask_question(blind_id):
#     file = request.files.get("image")
#     question = request.form.get("question")
#
#     if not file or not question:
#         return jsonify({"error": "Image and question are required"}), 400
#
#     try:
#         # Process image
#         objects, properties, scene_graph, preview_path = process_image(file)
#
#         scene_handler = SceneHandler(objects, scene_graph, properties)
#
#         print("\n[DEBUG] Objects, Scene Graph, Properties:")
#         scene_handler.debug()
#
#         # Ask question
#         answer = scene_handler.ask(question)
#         if not answer:
#             answer = hybrid_qa.answer(question)
#         if not answer:
#             return jsonify({"error": "Could not generate a valid answer."}), 400
#
#         # Create triplets for API
#         scene_triplets = [
#             {"from": rel["from"], "relation": rel["relation"], "to": rel["to"]}
#             for rel in scene_graph
#         ]
#
#         # Prepare detections for frontend
#         detections_list = []
#         for prop in properties:
#             detections_list.append({
#                 "label": prop.get("label"),
#                 "bbox": prop.get("bbox"),
#                 "color": prop.get("color", "unknown"),
#                 "shape": prop.get("shape", "unknown"),
#                 "emotion": prop.get("emotion", "not_applicable")
#             })
#
#         # Save blind user query
#         created_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
#         BlindHistoryModel().create_query(question, answer, preview_path, blind_id, created_at)
#
#         # Return only relative path (frontend will add LAN)
#         return jsonify({
#             "answer": answer,
#             "detections": detections_list,
#             "scene_graph": scene_triplets,
#             "image_path": preview_path   # ✔ relative ONLY
#         })
#
#     except Exception as e:
#         logging.exception("Error processing /getanswer")
#         return jsonify({"error": "Something went wrong", "details": str(e)}), 500



#New
from flask import Blueprint, request, jsonify
from Controllers.AnswerHandler import AnswerHandler
from Models.cfg_models import CFGModel
from Controllers.ImageHandler import ImageHandler
from Controllers.ObjectDetectionHandler import ObjectDetectionHandler
from Controllers.PropertiesHandler import PropertyHandler
from Controllers.SceneGraphHandler import SceneGraphHandler
from Controllers.SceneHandler import SceneHandler
import cv2
from Models.BlindHistory_models import BlindHistoryModel

import hashlib
from datetime import datetime
import os
import logging
from Controllers.Answer_Engine import HybridKGBasedQA
answer_routes = Blueprint("answer_routes", __name__)

# ---------------- Handlers ----------------
image_handler = ImageHandler()
detector = ObjectDetectionHandler()
property_handler = PropertyHandler()
scene_builder = SceneGraphHandler()
cfg_model = CFGModel()
answer_handler = AnswerHandler(cfg_model)
import re
hybrid_qa=HybridKGBasedQA(r"D:\PyCharm Project\NS_VQA\Controllers\KnowledgeGraphs")

# ---------------- Helpers ----------------
def get_image_hash(file_bytes):
    return hashlib.md5(file_bytes).hexdigest()

def process_image(file):
    """
    Process the image fresh every time.
    """
    image_bytes = file.read()
    file.seek(0)
    image_hash = get_image_hash(image_bytes)

    # Save the uploaded image
    image_path = image_handler.save_image(file, upload_dir="static/AnswerPics", convert_webp=True)
    image = image_handler.load_image(image_path)

    # Detect objects
    detections = detector.detect_objects(image_path)
    detections_with_props = property_handler.assign_properties(image, detections)

    # Build scene graph adjacency matrix
    scene_matrix = scene_builder.build_adjacency_matrix(detections_with_props)

    # Prepare objects + relationship list
    objects = [det['label'] for det in detections_with_props]
    props_dict = {det['label']: det for det in detections_with_props}

    relationships = []
    for i in range(1, len(scene_matrix)):
        src = scene_matrix[i][0]
        for j in range(1, len(scene_matrix[i])):
            rel = scene_matrix[i][j]
            if rel:
                tgt = scene_matrix[0][j]
                relationships.append({
                    "from": src,
                    "to": tgt,
                    "relation": rel
                })

    # ------------------------------
    # SAVE PREVIEW IN static/answerreturned/
    # ------------------------------
    preview_dir = os.path.join("static", "answerreturned")
    os.makedirs(preview_dir, exist_ok=True)

    preview_filename = f"preview_{image_hash}.jpg"
    preview_path = os.path.join(preview_dir, preview_filename)

    # Draw bounding boxes
    for det in detections_with_props:
        x, y, w, h = det['bbox']
        label = det['label']
        cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
        cv2.putText(image, label, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 1)

    cv2.imwrite(preview_path, image)

    # Return ONLY relative path (NO URL)
    relative_preview_path = f"static/answerreturned/{preview_filename}"

    return objects, [props_dict[obj] for obj in objects], relationships, relative_preview_path


def split_questions(question_text):
    """
    Splits compound questions using 'and' or 'or'.
    Ensures exactly one '?' at the end of each question.
    """

    q_lower = question_text.lower().strip()

    # Split by ' and ' OR ' or '
    parts = re.split(r'\s+(?:and|or)\s+', q_lower)

    final_questions = []
    for p in parts:
        p = p.strip()

        # 🔑 Remove any trailing punctuation from each part
        p = re.sub(r'[.!?]+$', '', p)

        if p:
            final_questions.append(p + '?')

    return final_questions

# ---------------- Flask Route ----------------
@answer_routes.route("/getanswer/<int:blind_id>", methods=["POST"])
def ask_question(blind_id):
    file = request.files.get("image")
    question = request.form.get("question")
    print(question ,"Recieved from postman")
    if not file or not question:
        return jsonify({"error": "Image and question are required"}), 400

    try:
        # Process image
        objects, properties, scene_graph, preview_path = process_image(file)

        scene_handler = SceneHandler(objects, scene_graph, properties)

        print("\n[DEBUG] Objects, Scene Graph, Properties:")
        scene_handler.debug()

        #
        # # Ask question
        # answer = scene_handler.ask(question)
        # if not answer:
        #     answer = hybrid_qa.answer(question)
        # if not answer:
        #     return jsonify({"error": "Could not generate a valid answer."}), 400

        # Split question if compound

        questions = split_questions(question)
        print("Questions I got are : ",questions)
        answers = []

        # Simple iteration first
        for q in questions:
            # 1. Try Scene Handler
            print("Question going to ask function : ",q)
            ans = scene_handler.ask(q)

            # 2. Try Hybrid QA
            if not ans:
                ans = hybrid_qa.answer(q)

            if ans:
                answers.append(ans)
            else:
                answers.append("I couldn't find an answer for that part.")

        # Join answers
        full_answer = " and ".join(answers)

        if not full_answer.strip():
            return jsonify({"error": "Could not generate a valid answer."}), 400

        # Create triplets for API
        scene_triplets = [
            {"from": rel["from"], "relation": rel["relation"], "to": rel["to"]}
            for rel in scene_graph
        ]

        # Prepare detections for frontend
        detections_list = []
        for prop in properties:
            detections_list.append({
                "label": prop.get("label"),
                "bbox": prop.get("bbox"),
                "color": prop.get("color", "unknown"),
                "shape": prop.get("shape", "unknown"),
                "emotion": prop.get("emotion", "not_applicable")
            })

        # Save blind user query
        created_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        BlindHistoryModel().create_query(question, full_answer, preview_path, blind_id, created_at)

        # Return only relative path (frontend will add LAN)
        return jsonify({
            "answer": full_answer,
            "detections": detections_list,
            "scene_graph": scene_triplets,
            "image_path": preview_path   # ✔ relative ONLY
        })

    except Exception as e:
        logging.exception("Error processing /getanswer")
        return jsonify({"error": "Something went wrong", "details": str(e)}), 500