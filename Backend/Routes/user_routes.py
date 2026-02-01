# from flask import Blueprint, request, jsonify
# from Models.user_models import UserModel

# user_routes = Blueprint("user_routes", __name__)
# user_model = UserModel()  # instantiate the class

# @user_routes.route('/getAll', methods=['GET'])
# def get_users():
#     users = user_model.get_all_users()
#     return jsonify([{'id': r[0], 'name': r[1], 'role': r[2], 'assistant_id': r[3]} for r in users])

# @user_routes.route('/create', methods=['POST'])
# def create_user():
#     try:
#         data = request.json
#         user_model.create_user(data['name'], data['role'], data.get('assistant_id'))

#         return jsonify({'message': 'User created'}), 201
#     except ValueError as ve:
#        return jsonify({'error': str(ve)}), 400
#     except Exception as e:
#         return jsonify({'error': 'Something went wrong', 'details': str(e)}), 500

# @user_routes.route('/users/<int:user_id>', methods=['PUT'])
# def update_user(user_id):
#     data = request.form
#     user_model.update_user(user_id, data['name'], data['role'], data.get('assistant_id'))
#     return jsonify({'message': 'User updated'})

# @user_routes.route('/users/<int:user_id>', methods=['DELETE'])
# def delete_user(user_id):
#     user_model.delete_user(user_id)
#     return jsonify({'message': 'User deleted'})

# @user_routes.route('/users/blind', methods=['GET'])
# def get_blind_users():
#     users = [u for u in user_model.get_all_users() if u[2].lower() == 'blind']
#     return jsonify([{'id': u[0], 'name': u[1], 'role': u[2], 'assistant_id': u[3]} for u in users])

# @user_routes.route('/users/assistant', methods=['GET'])
# def get_assistants():
#     users = [u for u in user_model.get_all_users() if u[2].lower() == 'assistant']
#     return jsonify([{'id': u[0], 'name': u[1], 'role': u[2], 'assistant_id': u[3]} for u in users])

# @user_routes.route('/users/unassigned', methods=['GET'])
# def get_unassigned_blinds():
#     users = user_model.get_all_users()
#     unassigned = [u for u in users if u[2].lower() == 'blind' and not u[3]]
#     return jsonify([{'id': u[0], 'name': u[1]} for u in unassigned])

# @user_routes.route('/users/<int:user_id>', methods=['GET'])
# def get_user_by_id(user_id):
#     users = user_model.get_all_users()
#     match = next((u for u in users if u[0] == user_id), None)
#     if match:
#         return jsonify({'id': match[0], 'name': match[1], 'role': match[2], 'assistant_id': match[3]})
#     return jsonify({'error': 'User not found'}), 404

# @user_routes.route('/users/<int:assistant_id>/assigned', methods=['GET'])
# def get_assigned_blinds(assistant_id):
#     users = user_model.get_all_users()
#     assigned = [u for u in users if u[3] == assistant_id and u[2].lower() == 'blind']
#     return jsonify([{'id': u[0], 'name': u[1]} for u in assigned])