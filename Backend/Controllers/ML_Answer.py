import os
import json
import re
import joblib
import numpy as np


# Try importing pyttsx3
try:
    import pyttsx3
    TTS_AVAILABLE = True
except ImportError:
    TTS_AVAILABLE = False


class MLKGBasedQA:
    def __init__(
        self,
        kg_folder,
        model_path=r"D:\PyCharm Project\NS_VQA\modelsNSVQA\relation_classifier_fahad.pkl",
        vectorizer_path=r"D:\PyCharm Project\NS_VQA\modelsNSVQA\vectorizer_fahad.pkl",
        confidence_threshold=0.8
    ):
        self.kg_folder = kg_folder
        self.confidence_threshold = confidence_threshold
        self.engine = pyttsx3.init() if TTS_AVAILABLE else None

        # Load KG
        self.kg = self.load_kg()
        self.objects = list(self.kg.keys()) or ["dummy_object"]

        # Load ML models
        self.clf = joblib.load(model_path)
        self.vectorizer = joblib.load(vectorizer_path)

        # Answer templates
        self.templates = {
            "used for": "{object} is used for {value}.",
            "has part": "{object} consists of {value}.",
            "part of": "{object} is part of {value}.",
            "material used": "{object} is made from {value}.",
            "subclass of": "{object} belongs to {value}.",
            "lifespan": "{object} typically lasts {value}.",
            "weight": "{object} weighs around {value}.",
            "height": "{object} has a height of {value}.",
            "color": "{object} is available in {value}.",
            "manufacturer": "{object} is manufactured by {value}."
        }

    # -------------------------
    # TEXT TO SPEECH
    # -------------------------
    def speak(self, text):
        if not TTS_AVAILABLE or not self.engine:
            return
        try:
            self.engine.say(text)
            self.engine.runAndWait()
        except Exception as e:
            print("TTS error:", e)

    # -------------------------
    # LOAD KNOWLEDGE GRAPH
    # -------------------------
    def load_kg(self):
        kg = {}
        if not os.path.exists(self.kg_folder):
            print(f"KG folder not found: {self.kg_folder}")
            return kg

        for file in os.listdir(self.kg_folder):
            if file.endswith(".json"):
                with open(os.path.join(self.kg_folder, file), "r", encoding="utf-8") as f:
                    data = json.load(f)

                obj = data["object"].lower()
                kg[obj] = {}

                for _, relation, value in data["triplets"]:
                    kg[obj].setdefault(relation.lower(), []).append(value)

        return kg

    # -------------------------
    # RELATION DETECTION (ML)
    # -------------------------
    def detect_relation(self, question):
        vec = self.vectorizer.transform([question])
        probs = self.clf.predict_proba(vec)[0]

        best_idx = np.argmax(probs)
        confidence = probs[best_idx]
        relation = self.clf.classes_[best_idx]

        if confidence < self.confidence_threshold:
            return None

        return relation

    # -------------------------
    # OBJECT DETECTION
    # -------------------------
    def detect_object(self, question):
        q = question.lower()
        matches = []

        for obj in self.objects:
            pattern = r"\b" + re.escape(obj) + r"\b"
            if re.search(pattern, q):
                matches.append(obj)

        if matches:
            return max(matches, key=len)  # longest match

        return None

    # -------------------------
    # ANSWER
    # -------------------------
    def answer(self, question):
        # 1️⃣ Relation
        relation = self.detect_relation(question)
        if not relation:
            return None  # IMPORTANT for hybrid fallback

        # 2️⃣ Object
        obj = self.detect_object(question)
        if not obj:
            return None

        # 3️⃣ KG lookup
        if relation not in self.kg[obj]:
            return None

        value = ", ".join(self.kg[obj][relation])
        template = self.templates.get(relation)

        return template.format(
            object=obj.capitalize(),
            value=value
        )


# =========================
# INTERACTIVE TEST
# =========================
if __name__ == "__main__":
    KG_FOLDER = r"D:\PyCharm Project\NS_VQA\Controllers\KnowledgeGraphs"
    qa = MLKGBasedQA(KG_FOLDER)

    print("\n=== CLASS-BASED ML QA ===")
    print("Type 'exit' to quit\n")

    while True:
        q = input("Q: ")
        if q.lower() == "exit":
            break

        ans = qa.answer(q)
        if not ans:
            ans = "Sorry, I could not understand your question."

        print("A:", ans)
        qa.speak(ans)