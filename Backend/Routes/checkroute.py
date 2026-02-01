from flask import Blueprint, request, jsonify
check_routes = Blueprint("check_routes", __name__)

@check_routes.route('/check', methods=['GET'])
def check():
    return jsonify({
        "message": "Checking this Route "
    })