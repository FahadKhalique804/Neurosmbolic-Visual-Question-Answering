# # # ============================
# # # routes/ObjectRoutes.py
# # # ============================
# # from flask import Blueprint, request, jsonify, send_file
# # from Controllers.ImageHandler import ImageHandler
# # from Controllers.ObjectDetectionHandler import ObjectDetectionHandler
# # from Controllers.SceneGraphHandler import SceneGraphHandler
# # from Controllers.PropertiesHandler import PropertyHandler
# # import hashlib
# # import cv2
# # import os
# # from nltk import word_tokenize, pos_tag
# #
# # object_routes = Blueprint("object_routes", __name__)
# # image_handler = ImageHandler()
# # detector = ObjectDetectionHandler()
# # scene_builder = SceneGraphHandler(image_height=720,near_thresh=50,overlap_thresh=0.2)
# # property_handler = PropertyHandler()
# #
# #
# # # Cache processed data keyed by image hash
# # image_cache = {}
# #
# # def get_image_hash(file_bytes):
# #     return hashlib.md5(file_bytes).hexdigest()
# #
# # def process_image_if_needed(file):
# #     image_bytes = file.read()
# #     file.seek(0)  # reset pointer
# #     img_hash = get_image_hash(image_bytes)
# #
# #     if img_hash not in image_cache:
# #         print("🔁 Processing new image...")
# #         image_path = image_handler.save_image(file)
# #         image = image_handler.load_image(image_path)
# #
# #
# #         # Detect objects using ObjectDetectionHandler
# #         detections = detector.detect_objects(image_path)
# #         print(detections)
# #         # Assign properties like color, shape, and emotion using PropertyHandler
# #         detections_with_props = property_handler.assign_properties(image, detections)
# #         print(detections_with_props)
# #
# #         objects_for_scenegraph = [{'label': det['label'], 'bbox': det['bbox']} for det in detections_with_props]
# #
# #         # Build the scene graph adjacency matrix
# #         scene_graph = scene_builder.build_adjacency_matrix(objects_for_scenegraph)
# #         print(scene_graph)
# #         # Draw boxes on image and sav   e preview
# #         for det in detections_with_props:
# #             x, y, w, h = det['bbox']
# #             label = det['label']
# #             cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
# #             cv2.putText(image, label, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 1)
# #
# #         preview_path = os.path.join("uploads", f"preview_{img_hash}.jpg")
# #         cv2.imwrite(preview_path, image)
# #
# #         image_cache[img_hash] = {
# #             'detections': detections,
# #             'props': detections_with_props,
# #             'scene_graph': scene_graph,
# #             'image_path': preview_path
# #         }
# #     else:
# #         print("✅ Image already processed. Using cached results.")
# #
# #     return img_hash
# #
# #
# # @object_routes.route('/getlabels', methods=['POST'])
# # def get_labels():
# #     if 'image' not in request.files:
# #         return jsonify({"error": "No image provided."}), 400
# #
# #     file = request.files['image']
# #     image_id = process_image_if_needed(file)
# #     return jsonify(image_cache[image_id]['detections'])
# #
# #
# # @object_routes.route('/getlistofobjs', methods=['POST'])
# # def get_list_of_objects():
# #     if 'image' not in request.files:
# #         return jsonify({"error": "No image provided."}), 400
# #
# #     file = request.files['image']
# #     image_id = process_image_if_needed(file)
# #     labels = [obj['label'] for obj in image_cache[image_id]['props']]
# #     return jsonify(labels)
# #
# #
# # @object_routes.route('/getshape/<string:label>', methods=['POST'])
# # def get_shape_by_label(label):
# #     if 'image' not in request.files:
# #         return jsonify({"error": "No image provided."}), 400
# #
# #     file = request.files['image']
# #     image_id = process_image_if_needed(file)
# #     for obj in image_cache[image_id]['props']:
# #         if obj['label'].lower() == label.lower():
# #             return jsonify({"message": f"The shape of {label.capitalize()} is {obj['shape']}"})
# #     return jsonify({"error": "Object not found."}), 404
# #
# #
# # @object_routes.route('/getcolor/<string:label>', methods=['POST'])
# # def get_color_by_label(label):
# #     if 'image' not in request.files:
# #         return jsonify({"error": "No image provided."}), 400
# #
# #     file = request.files['image']
# #     image_id = process_image_if_needed(file)
# #     for obj in image_cache[image_id]['props']:
# #         if obj['label'].lower() == label.lower():
# #             return jsonify({"message": f"The color of {label.capitalize()} is {obj['color']}"})
# #     return jsonify({"error": "Object not found."}), 404
# #
# #
# # @object_routes.route('/getdetectedimage', methods=['POST'])
# # def get_detected_image():
# #     if 'image' not in request.files:
# #         return jsonify({"error": "No image provided."}), 400
# #
# #     file = request.files['image']
# #     image_id = process_image_if_needed(file)
# #     return send_file(image_cache[image_id]['image_path'], mimetype='image/jpeg')
# #
# #
# # # @object_routes.route('/getscenegraph', methods=['POST'])
# # # def get_scene_graph():
# # #     if 'image' not in request.files:
# # #         return jsonify({"error": "No image provided."}), 400
# # #
# # #     file = request.files['image']
# # #     image_id = process_image_if_needed(file)
# # #     matrix = image_cache[image_id]['scene_graph']
# # #
# # #     objects = matrix[0][1:]  # skip first empty cell
# # #     relationships = []
# # #
# # #     for i in range(1, len(matrix)):
# # #         source = matrix[i][0]
# # #         for j in range(1, len(matrix[i])):
# # #             relation = matrix[i][j]
# # #             if relation:  # not empty
# # #                 target = matrix[0][j]
# # #                 relationships.append({
# # #                     "from": source,
# # #                     "to": target,
# # #                     "relation": relation
# # #                 })
# # #
# # #     return jsonify({"scene_graph": relationships})
# #
# #
# # @object_routes.route('/getscenegraph', methods=['POST'])
# # def get_scene_graph():
# #     if 'image' not in request.files:
# #         return jsonify({"error": "No image provided."}), 400
# #
# #     file = request.files['image']
# #
# #     # Process the image
# #     image_id = process_image_if_needed(file)
# #
# #     # Retrieve the scene graph matrix from cache
# #     matrix = image_cache[image_id]['scene_graph']
# #
# #     # Get the objects and relationships from the scene graph matrix
# #     objects = matrix[0][1:]  # skip first empty cell
# #     relationships = []
# #
# #     # Extract the relationships from the adjacency matrix
# #     for i in range(1, len(matrix)):
# #         source = matrix[i][0]
# #         for j in range(1, len(matrix[i])):
# #             relation = matrix[i][j]
# #             if relation:  # If the relation is not empty
# #                 target = matrix[0][j]
# #                 relationships.append({
# #                     "from": source,
# #                     "to": target,
# #                     "relation": relation
# #                 })
# #
# #     return jsonify({"scene_graph": relationships})
# #
# #
# #
# #
# # @object_routes.route('/getbbox/<string:label>', methods=['POST'])
# # def get_bounding_box_by_label(label):
# #     if 'image' not in request.files:
# #         return jsonify({"error": "No image provided."}), 400
# #
# #     file = request.files['image']
# #     image_id = process_image_if_needed(file)
# #     for obj in image_cache[image_id]['detections']:
# #         if obj['label'].lower() == label.lower():
# #             return jsonify({"message": f"The bounding box of {label.capitalize()} is {obj['bbox']}"})
# #     return jsonify({"error": "Object not found."}), 404
# #
#
#
# # ============================
# # routes/ObjectRoutes.py
# # ============================
# from flask import Blueprint, request, jsonify, send_file
# from Controllers.ImageHandler import ImageHandler
# from Controllers.ObjectDetectionHandler import ObjectDetectionHandler
# from Controllers.SceneGraphConfigure import SceneGraphHandler
# from Controllers.PropertiesHandler import PropertyHandler
# import hashlib
# import cv2
# import os
# from nltk import word_tokenize, pos_tag
#
# object_routes = Blueprint("object_routes", __name__)
#
# image_handler = ImageHandler()
# detector = ObjectDetectionHandler()
# scene_builder = SceneGraphHandler()
# property_handler = PropertyHandler()
#
# # Cache processed data keyed by image hash
# image_cache = {}
#
#
# def get_image_hash(file_bytes):
#     return hashlib.md5(file_bytes).hexdigest()
#
#
# def process_image_if_needed(file):
#     image_bytes = file.read()
#     file.seek(0)  # reset pointer
#     img_hash = get_image_hash(image_bytes)
#
#     if img_hash not in image_cache:
#         print("🔁 Processing new image...")
#         image_path = image_handler.save_image(file)
#         image = image_handler.load_image(image_path)
#
#         detections = detector.detect_objects(image_path)
#         print("Detections Done")
#         detections_with_props = property_handler.assign_properties(image, detections)
#         print("Detections with props Done")
#         scene_graph = scene_builder.build_adjacency_matrix(detections_with_props)
#         print("Scene Graph Issue")
#
#         # Draw boxes on image and save preview
#         for det in detections_with_props:
#             x, y, w, h = det['bbox']
#             label = det['label']
#             cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
#             cv2.putText(image, label, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 1)
#
#         preview_path = os.path.join("uploads", f"preview_{img_hash}.jpg")
#         cv2.imwrite(preview_path, image)
#
#         image_cache[img_hash] = {
#             'detections': detections,
#             'props': detections_with_props,
#             'scene_graph': scene_graph,
#             'image_path': preview_path
#         }
#     else:
#         print("✅ Image already processed. Using cached results.")
#
#     return img_hash
#
#
# @object_routes.route('/getlabels', methods=['POST'])
# def get_labels():
#     if 'image' not in request.files:
#         return jsonify({"error": "No image provided."}), 400
#
#     file = request.files['image']
#     image_id = process_image_if_needed(file)
#     return jsonify(image_cache[image_id]['detections'])
#
#
# @object_routes.route('/getlistofobjs', methods=['POST'])
# def get_list_of_objects():
#     if 'image' not in request.files:
#         return jsonify({"error": "No image provided."}), 400
#
#     file = request.files['image']
#     image_id = process_image_if_needed(file)
#     labels = [obj['label'] for obj in image_cache[image_id]['props']]
#     return jsonify(labels)
#
#
# @object_routes.route('/getshape/<string:label>', methods=['POST'])
# def get_shape_by_label(label):
#     if 'image' not in request.files:
#         return jsonify({"error": "No image provided."}), 400
#
#     file = request.files['image']
#     image_id = process_image_if_needed(file)
#     for obj in image_cache[image_id]['props']:
#         if obj['label'].lower() == label.lower():
#             return jsonify({"message": f"The shape of {label.capitalize()} is {obj['shape']}"})
#     return jsonify({"error": "Object not found."}), 404
#
#
# @object_routes.route('/getcolor/<string:label>', methods=['POST'])
# def get_color_by_label(label):
#     if 'image' not in request.files:
#         return jsonify({"error": "No image provided."}), 400
#
#     file = request.files['image']
#     image_id = process_image_if_needed(file)
#     for obj in image_cache[image_id]['props']:
#         if obj['label'].lower() == label.lower():
#             return jsonify({"message": f"The color of {label.capitalize()} is {obj['color']}"})
#     return jsonify({"error": "Object not found."}), 404
#
#
# @object_routes.route('/getdetectedimage', methods=['POST'])
# def get_detected_image():
#     if 'image' not in request.files:
#         return jsonify({"error": "No image provided."}), 400
#
#     file = request.files['image']
#     image_id = process_image_if_needed(file)
#     return send_file(image_cache[image_id]['image_path'], mimetype='image/jpeg')
#
#
# @object_routes.route('/getscenegraph', methods=['POST'])
# def get_scene_graph():
#     if 'image' not in request.files:
#         return jsonify({"error": "No image provided."}), 400
#
#     print("All values received ok : ")
#     file = request.files['image']
#     image_id = process_image_if_needed(file)
#     matrix = image_cache[image_id]['scene_graph']
#
#     objects = matrix[0][1:]  # skip first empty cell
#     relationships = []
#     print(objects)
#     for i in range(1, len(matrix)):
#         source = matrix[i][0]
#         for j in range(1, len(matrix[i])):
#             relation = matrix[i][j]
#             if relation:  # not empty
#                 target = matrix[0][j]
#                 relationships.append({
#                     "from": source,
#                     "to": target,
#                     "relation": relation
#                 })
#
#     return jsonify({"scene_graph": relationships})
#
#
# @object_routes.route('/getbbox/<string:label>', methods=['POST'])
# def get_bounding_box_by_label(label):
#     if 'image' not in request.files:
#         return jsonify({"error": "No image provided."}), 400
#
#     file = request.files['image']
#     image_id = process_image_if_needed(file)
#     for obj in image_cache[image_id]['detections']:
#         if obj['label'].lower() == label.lower():
#             return jsonify({"message": f"The bounding box of {label.capitalize()} is {obj['bbox']}"})
#     return jsonify({"error": "Object not found."}), 404


from flask import Blueprint, request, jsonify, send_file
from Controllers.ImageHandler import ImageHandler
from Controllers.ObjectDetectionHandler import ObjectDetectionHandler
from Controllers.SceneGraphHandler import SceneGraphHandler
from Controllers.PropertiesHandler import PropertyHandler
import hashlib
import cv2
import os

object_routes = Blueprint("object_routes", __name__)

image_handler = ImageHandler()
detector = ObjectDetectionHandler()
scene_builder = SceneGraphHandler()
property_handler = PropertyHandler()


def get_image_hash(file_bytes):
    return hashlib.md5(file_bytes).hexdigest()


def process_image(file):
    """
    Process the image from scratch every time it is uploaded.
    """
    image_bytes = file.read()
    file.seek(0)  # reset pointer
    image_hash = get_image_hash(image_bytes)

    # Process the image
    image_path = image_handler.save_image(file)
    image = image_handler.load_image(image_path)

    # Detect objects
    detections = detector.detect_objects(image_path)
    print("Detections Done")
    detections_with_props = property_handler.assign_properties(image, detections)
    print("Detections with properties Done")

    # Build Scene Graph
    scene_graph = scene_builder.build_adjacency_matrix(detections_with_props)
    print("Scene Graph Done")

    # Draw bounding boxes on image and save preview
    for det in detections_with_props:
        x, y, w, h = det['bbox']
        label = det['label']
        cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
        cv2.putText(image, label, (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 1)

    # Save preview image
    preview_path = os.path.join("uploads", f"preview_{image_hash}.jpg")
    cv2.imwrite(preview_path, image)

    return {
        'detections': detections,
        'props': detections_with_props,
        'scene_graph': scene_graph,
        'image_path': preview_path
    }

@object_routes.route('/getscenegraph', methods=['POST'])
def get_scene_graph():
    if 'image' not in request.files:
        return jsonify({"error": "No image provided."}), 400

    file = request.files['image']
    result = process_image(file)

    matrix = result['scene_graph']
    objects = matrix[0][1:]  # skip first empty cell
    relationships = []

    for i in range(1, len(matrix)):
        source = matrix[i][0]
        for j in range(1, len(matrix[i])):
            relation = matrix[i][j]
            if relation:  # not empty
                target = matrix[0][j]
                relationships.append({
                    "from": source,
                    "to": target,
                    "relation": relation
                })

    return jsonify({"scene_graph": relationships,
                    "objects":objects,
                    "properties":result['props']
    })

@object_routes.route('/getlabels', methods=['POST'])
def get_labels():
    if 'image' not in request.files:
        return jsonify({"error": "No image provided."}), 400

    file = request.files['image']
    result = process_image(file)
    return jsonify(result['detections'])


@object_routes.route('/getlistofobjs', methods=['POST'])
def get_list_of_objects():
    if 'image' not in request.files:
        return jsonify({"error": "No image provided."}), 400

    file = request.files['image']
    result = process_image(file)
    labels = [obj['label'] for obj in result['props']]
    return jsonify(labels)


@object_routes.route('/getshape/<string:label>', methods=['POST'])
def get_shape_by_label(label):
    if 'image' not in request.files:
        return jsonify({"error": "No image provided."}), 400

    file = request.files['image']
    result = process_image(file)

    for obj in result['props']:
        if obj['label'].lower() == label.lower():
            return jsonify({"message": f"The shape of {label.capitalize()} is {obj['shape']}"})

    return jsonify({"error": "Object not found."}), 404


@object_routes.route('/getcolor/<string:label>', methods=['POST'])
def get_color_by_label(label):
    if 'image' not in request.files:
        return jsonify({"error": "No image provided."}), 400

    file = request.files['image']
    result = process_image(file)

    for obj in result['props']:
        if obj['label'].lower() == label.lower():
            return jsonify({"message": f"The color of {label.capitalize()} is {obj['color']}"})

    return jsonify({"error": "Object not found."}), 404


@object_routes.route('/getdetectedimage', methods=['POST'])
def get_detected_image():
    if 'image' not in request.files:
        return jsonify({"error": "No image provided."}), 400

    file = request.files['image']
    result = process_image(file)

    return send_file(result['image_path'], mimetype='image/jpeg')




@object_routes.route('/getbbox/<string:label>', methods=['POST'])
def get_bounding_box_by_label(label):
    if 'image' not in request.files:
        return jsonify({"error": "No image provided."}), 400

    file = request.files['image']
    result = process_image(file)

    for obj in result['detections']:
        if obj['label'].lower() == label.lower():
            return jsonify({"message": f"The bounding box of {label.capitalize()} is {obj['bbox']}"})

    return jsonify({"error": "Object not found."}), 404