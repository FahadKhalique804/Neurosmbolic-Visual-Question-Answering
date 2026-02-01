import os
from flask import Flask, send_from_directory,Blueprint

direct_routes = Blueprint("direct_routes", __name__)


# # Serve BlindPics
# @direct_routes.route('/BlindPics/<filename>')
# def blind_pics(filename):
#     return send_from_directory('static/BlindPics', filename)
#
# @direct_routes.route('/ContactPics/<filename>')
# def contact_pics(filename):
#     return send_from_directory('static/ContactPics', filename)
#
# @direct_routes.route('/AssistantPics/<filename>')
# def assis_pics(filename):
#     return send_from_directory('static/AssistantPics', filename)

# ✅ Point directly to your real static folder
STATIC_DIR = r"D:\PyCharm Project\NS_VQA\static"

@direct_routes.route('/ContactPics/<filename>')
def contact_pics(filename):
    return send_from_directory(os.path.join(STATIC_DIR, 'ContactPics'), filename)


@direct_routes.route('/BlindPics/<filename>')
def blind_pics(filename):
    return send_from_directory(os.path.join(STATIC_DIR, 'BlindPics'), filename)


@direct_routes.route('/AssistantPics/<filename>')
def assistant_pics(filename):
    return send_from_directory(os.path.join(STATIC_DIR, 'AssistantPics'), filename)
