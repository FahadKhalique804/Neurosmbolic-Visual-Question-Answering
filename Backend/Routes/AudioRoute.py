from flask import Flask, request, jsonify,Blueprint
import whisper
import os
from nltk.tokenize import word_tokenize

audioRoutes = Blueprint('AudioRoutes', __name__)
model = whisper.load_model("base")  # local Whisper model

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@audioRoutes.route("/transcribe", methods=["POST"])
def transcribe():
    if "audio" not in request.files:
        print("No audio file received!")
        return jsonify({"error": "No audio file sent"}), 400

    audio_file = request.files.get("audio")
    if not audio_file:
        print("Audio file is None!")
        return jsonify({"error": "Audio file is empty"}), 400

    print("Received file:", audio_file.filename)
    filepath = os.path.join(UPLOAD_FOLDER, audio_file.filename)
    audio_file.save(filepath)
    print("Saved file to:", filepath)

    result = model.transcribe(
        filepath,
        task="translate",
        language="en"
    )
    text = result["text"].strip()
    print("Transcription:", text)

    return jsonify({"text": text})

# @audioRoutes.route("/voice/command", methods=["POST"])
# def voice_command():
#     # 0️⃣ Check audio file
#     if "audio" not in request.files:
#         return jsonify({"error": "No audio file sent"}), 400
#
#     audio_file = request.files["audio"]
#     filepath = os.path.join(UPLOAD_FOLDER, audio_file.filename)
#     audio_file.save(filepath)
#
#     # 1️⃣ Transcribe audio
#     result = model.transcribe(filepath)
#     text = result.get("text", "").strip().lower()
#     print("Transcribed Text:", text)
#
#     # 2️⃣ Clean text: replace commas with spaces, remove extra spaces
#     cleaned_text = " ".join(text.replace(",", " ").split())
#     print("Cleaned Text:", cleaned_text)
#
#     # 3️⃣ Tokenization
#     tokens = cleaned_text.split()
#     print("Tokens:", tokens)
#
#     # 4️⃣ Fixed keyword list (ORDER MATTERS)
#     keywords = ["image", "continue", "start","temporal", "back","ask"]
#
#     # 5️⃣ Keyword detection
#     detected = None
#     for word in tokens:
#         if word in keywords:
#             detected = word
#             break
#
#     # 6️⃣ Response
#     if detected:
#         return jsonify({
#             "text": cleaned_text,
#             "command": detected,
#             "message": f"{detected} detected"
#
#         })
#
#     return jsonify({
#         "text": cleaned_text,
#         "command": None,
#         "message": "No keyword detected"
#     })



#Real
@audioRoutes.route("/voice/command", methods=["POST"])
def voice_command():
    # 0️⃣ Check audio file
    if "audio" not in request.files:
        return jsonify({"error": "No audio file sent"}), 400

    audio_file = request.files["audio"]
    filepath = os.path.join(UPLOAD_FOLDER, audio_file.filename)
    audio_file.save(filepath)
    #
    # 1️⃣ Transcribe audio
    result = model.transcribe(
        filepath,
        task="translate",
        language="en"
    )

    text = result.get("text", "").strip().lower()

    print("Transcribed Text:", text)

    # 2️⃣ Tokenize using NLTK (handles punctuation)

    tokens = word_tokenize(str(text))
    tokens.append(None)
    print(type(tokens))
    print("Tokens:", tokens)

    # 3️⃣ Fixed keyword list (ORDER MATTERS)
    keywords = ["image", "continue", "start", "temporal","back", "ask","toggle","monitor"]
    command=None
    # 4️⃣ Keyword detection
    detected = None
    for token in tokens:
        # token.lower()
        print(token)

        if token in keywords:
            id=tokens.index(token)
            print(f"Token {token} ID : {id}")
            print("last token",tokens[-1])
            print("last id of string",tokens.index(tokens[-1]))
            lid=tokens.index(tokens[-1])
            print("LID : ",lid)
            if token in ["toggle","monitor","temporal"] and tokens[id+1] in ["on","off",None] :
                print("in temporal toggle ")
                if(tokens[id+1])==None:
                    command=token
                else:
                    command = token + " " + tokens[id + 1]
                print("Detected:" ,command)
                detected=True
            else:
                print("one word")
                command=token
                detected=True
                print("Detected:", command)
            if detected:
                return jsonify({
                    "text": text,
                    "command": command,
                    "action": detected,  # 🔥 important
                    "message": f"{detected} detected"
                })

        else:
            print("not a keyword",token)
        # if detected:
        #     break
        # if token in keywords:
        #     detected = token
        #     break

    # 5️⃣ Response
    if detected:
        return jsonify({
            "text": text,
            "command": detected,
            "action": detected,  # 🔥 important
            "message": f"{detected} detected"
        })

    return jsonify({
        "text": text,
        "command": None,
        "message": "No keyword detected"
    })

