import warnings
warnings.filterwarnings("ignore", message="I/O operation on closed file")

from flask import Flask
from Routes.nlproutes import nlp_routes
from Routes.ContactPics import contact_routes
from Routes.Blind_Assistant import blind_assistant_bp
from Routes.BlindHistory import blind_routes
from Routes.objectroutes import object_routes
from Routes.answer_routes import answer_routes
from Routes.DirectoryRoutes import direct_routes
from Routes.AudioRoute import audioRoutes
from Routes.emotionroute import emotion_routes
from flask import send_from_directory
from flask_cors import CORS


app = Flask(__name__)


# Register Blueprint
app.register_blueprint(nlp_routes, url_prefix="/nlp")
app.register_blueprint(contact_routes, url_prefix="/contacts")
app.register_blueprint(blind_assistant_bp, url_prefix="/user")
app.register_blueprint(blind_routes, url_prefix="/blind")
app.register_blueprint(object_routes, url_prefix="/Image")
app.register_blueprint(answer_routes, url_prefix="/Ans")
app.register_blueprint(direct_routes, url_prefix="/static")
app.register_blueprint(audioRoutes, url_prefix="/audio" )
app.register_blueprint(emotion_routes, url_prefix="/emotion")


# @app.route('/uploads/<path:filename>')
# def serve_uploads(filename):
#     return send_from_directory("uploads", filename)

@app.route('/')
def home():
    return "API is running!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)





'6''4'