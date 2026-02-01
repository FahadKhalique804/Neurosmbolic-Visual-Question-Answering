from flask import Blueprint, request, jsonify
from Models.BlindModel import BlindModel
from Models.AssistantModel import AssistantModel
from Models.BlindAssistantModel import BlindAssistantModel
from Services.image_service import ImageService
from Services.file_service import FileService

blind_assistant_bp = Blueprint('blind_assistant', __name__)
BM = BlindModel()
AM = AssistantModel()
BAM = BlindAssistantModel()


# ===== Routes =====

@blind_assistant_bp.route('/blind-with-assistant', methods=['GET'])
def get_blind_with_assistant():
    """Fetch blind users with their assigned assistant"""
    data = BAM.get_blinds_with_assistants()  # must exist in BlindAssistantModel
    return jsonify([
        {
            "id": r[0],
            "blind_name": r[1],
            "blind_age": r[2],
            "blind_gender": r[3],
            "assistant_id": r[4],
            "assistant_name": r[5]
        }
        for r in data
    ])


@blind_assistant_bp.route('/login', methods=['POST'])
def get_username_password():
    print("in login route ")
    body = request.get_json()
    username = body["username"]
    password = body["password"]

    user = BAM.loginAssistant(username, password)  # must exist in AssistantModel
    if not user:
        return jsonify({"message": "No Id found ... Sign Up Plzz"}), 401

    return jsonify({
        "id": user[0],
        "name": user[1],
        "age": user[2],
        "gender": user[3],
        "pic": user[4],
        "message": "Login successful"

    })


@blind_assistant_bp.route('/assistant/<int:assistant_id>/blinds', methods=['GET'])
def get_blinds_by_assistant(assistant_id):
    """Fetch all blinds assigned to a specific assistant"""
    blinds = BAM.getBlindByAssistantId(assistant_id)
    return jsonify([
        {
            'id': r[0],
            'name': r[1],
            'age': r[2],
            'gender': r[3],
            'assistant_id': r[4],
            'pic': r[5]
        } for r in blinds
    ])


@blind_assistant_bp.route("/check-username", methods=["POST"])
def check_username():
    try:
        data = request.get_json()
        username = data["username"]

        if not username:
            return jsonify({"success": False, "message": "Username is required"}), 400

        exists = AM.check_username_exists(username)

        if exists:
            return jsonify({"success": False, "available": False, "message": "Username already taken"}), 200
        else:
            return jsonify({"success": True, "available": True, "message": "Username is available"}), 200

    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500


@blind_assistant_bp.route('/blinds/create', methods=['POST'])
def create_blind():
    try:
        # Form-data fields
        name = request.form['name'].strip()
        age = int(request.form['age'])
        gender = request.form['gender'].strip()
        assistant_id = int(request.form['assistant_id'])

        # Validate uploaded file
        if 'pic' not in request.files:
            return jsonify({"message": "Blind profile picture is required"}), 400

        pic_file = request.files['pic']
        if pic_file.filename == '':
            return jsonify({"message": "No selected file"}), 400
        if not pic_file.filename.lower().endswith(('.png', '.jpg', '.jpeg', '.webp')):
            return jsonify({"message": "Invalid file type"}), 400

        # Save image using ImageService (like assistant)
        saved_path = FileService.save_file(pic_file, folder="BlindPics", convert_webp=True)

        # Create blind in DB
        BM.createBlind(name, age, gender, assistant_id, saved_path)

        return jsonify({
            "success": True,
            "message": "Blind created successfully",
            "pic_path": saved_path
        }), 201

    except ValueError as ve:
        return jsonify({"message": str(ve)}), 400
    except Exception as e:
        import logging
        logging.exception("Error creating blind")
        return jsonify({
            "message": "Something went wrong",
            "details": str(e)
        }), 500


# Get all Blinds
@blind_assistant_bp.route('/blinds', methods=['GET'])
def get_blinds():
    blinds = BM.getAllblinds()
    result = [{"id": b[0], "name": b[1], "age": b[2], "gender": b[3], "assistant_id": b[4]} for b in blinds]
    return jsonify(result)


@blind_assistant_bp.route('/blinds/<int:blind_id>', methods=['GET'])
def get_blind(blind_id):
    b = BM.getBlindById(blind_id)
    if not b:
        return jsonify({"message": "Blind not found"}), 404
    return jsonify({"id": b[0],
                    "name": b[1],
                    "age": b[2],
                    "gender": b[3],
                    "assistant_id": b[4]
                    })


@blind_assistant_bp.route('blinds/update/<int:blind_id>', methods=['PUT'])
def update_blind(blind_id):
    try:
        data = request.get_json(force=True)
        BM.updateBlind(blind_id, **data)
        return jsonify({"message": "Blind updated"})
    except Exception as e:
        return jsonify({"message": "Something went wrong", "details": str(e)}), 500


# Delete Blind
@blind_assistant_bp.route('blinds/delete/<int:blind_id>', methods=['DELETE'])
def delete_blind(blind_id):
    try:
        BM.deleteBlind(blind_id)
        return jsonify({"message": "Blind deleted"})
    except Exception as e:
        return jsonify({"message": "Something went wrong", "details": str(e)}), 500


@blind_assistant_bp.route('/assis/create', methods=['POST'])
def create_assistant():
    try:
        print("in function assis/create")
        # form-data fields
        name = request.form['name']
        age = request.form['age']
        gender = request.form['gender']
        username = request.form['username']
        password = request.form['password']

        # get file
        if 'pic' not in request.files:
            return jsonify({"message": "Assistant picture is required"}), 400

        pic_file = request.files['pic']

        # use your generic image service to save as .webp
        from Services.file_service import FileService
        pic_path = FileService.save_file(pic_file, folder="AssistantPics", convert_webp=True)

        # create assistant in DB
        assistant_id = AM.createAssistant(name, age, gender, pic_path, username, password)
        print("assistant ID :",assistant_id)
        return jsonify({"success": True, "message": "Assistant created", "id": assistant_id}), 201

    except Exception as e:
        return jsonify({"message": "Something went wrong", "details": str(e)}), 500


# Get all Assistants
@blind_assistant_bp.route('/assis', methods=['GET'])
def get_assistants():
    assistants = AM.getAllAssistants()
    result = [{"id": a[0], "name": a[1], "age": a[2], "gender": a[3], "username": a[5]} for a in assistants]
    return jsonify(result)


# Get Assistant by ID
@blind_assistant_bp.route('/assis/<int:assistant_id>', methods=['GET'])
def get_assistant(assistant_id):
    a = AM.getAssistantById(assistant_id)
    if not a:
        return jsonify({"message": "Assistant not found"}), 404
    return jsonify({"id": a[0], "name": a[1], "age": a[2], "gender": a[3], "username": a[5]})


# Update Assistant
@blind_assistant_bp.route('/assis/update/<int:assistant_id>', methods=['PUT'])
def update_assistant(assistant_id):
    try:
        data = request.get_json(force=True)
        AM.updateAssistant(assistant_id, **data)
        return jsonify({"message": "Assistant updated"})
    except Exception as e:
        return jsonify({"message": "Something went wrong", "details": str(e)}), 500


# Delete Assistant
@blind_assistant_bp.route('/assis/delete/<int:assistant_id>', methods=['DELETE'])
def delete_assistant(assistant_id):
    try:
        AM.deleteAssistant(assistant_id)
        return jsonify({"message": "Assistant deleted"})
    except Exception as e:
        return jsonify({"message": "Something went wrong", "details": str(e)}), 500