import os
import json
import re

# Try importing pyttsx3
try:
    import pyttsx3
    TTS_AVAILABLE = True
except ImportError:
    TTS_AVAILABLE = False


class RegexKGBasedQA:
    def __init__(self, kg_folder):
        self.kg_folder = kg_folder
        self.kg = self.load_kg()
        self.objects = sorted(self.kg.keys(), key=len, reverse=True) or ["dummy_object"]
        self.engine = pyttsx3.init() if TTS_AVAILABLE else None

        self.relation_patterns = {
            "manufacturer": [
                r"who\s+manufactures", r"who\s+makes", r"who\s+produced",
                r"manufacturer", r"brand", r"company", r"maker"
            ],
            "material used": [
                r"material", r"made\s+of", r"made\s+from",
                r"consist\s+of", r"substance", r"composition"
            ],
            "color": [
                r"color", r"colour", r"hue", r"shade", r"paint"
            ],
            "weight": [
                r"weight", r"weigh", r"heavy", r"mass"
            ],
            "height": [
                r"height", r"tall", r"high"
            ],
            "lifespan": [
                r"lifespan", r"life\s+expectancy",
                r"how\s+long\s+.*last", r"duration", r"longevity"
            ],
            "subclass of": [
                r"subclass", r"category", r"type\s+of", r"kind\s+of",
                r"classification", r"define"
            ],
            "part of": [
                r"part\s+of", r"belong\s+to", r"included\s+in"
            ],
            "has part": [
                r"has\s+part", r"contain", r"composed\s+of",
                r"include", r"components", r"parts"
            ],
            "used for": [
                r"used\s+for", r"purpose", r"function",
                r"use", r"do\s+with", r"apply"
            ]
        }

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
    # LOAD KG
    # -------------------------
    def load_kg(self):
        kg = {}
        if not os.path.exists(self.kg_folder):
            print(f"KG folder not found: {self.kg_folder}")
            return kg

        for file in os.listdir(self.kg_folder):
            if file.lower().endswith(".json"):
                with open(os.path.join(self.kg_folder, file), "r", encoding="utf-8") as f:
                    data = json.load(f)

                obj = data["object"].lower()
                kg[obj] = {}

                for _, relation, value in data["triplets"]:
                    kg[obj].setdefault(relation.lower(), []).append(value)

        return kg

    # -------------------------
    # REGEX CLASSIFICATION
    # -------------------------
    def classify(self, question):
        q = question.lower().strip()

        # 1️⃣ Detect object
        found_obj = None
        for obj in self.objects:
            if re.search(r"\b" + re.escape(obj) + r"\b", q):
                found_obj = obj
                break

        if not found_obj:
            return None, None

        # Mask object for subclass patterns
        q_masked = re.sub(
            r"\b" + re.escape(found_obj) + r"\b",
            "<OBJECT>",
            q
        )

        # Strict "What is X?" → subclass
        if re.search(r"^what\s+is\s+(a|an|the)?\s*<OBJECT>\??$", q_masked):
            return found_obj, "subclass of"

        # Pattern matching
        for relation, patterns in self.relation_patterns.items():
            for pat in patterns:
                if re.search(pat, q_masked):
                    return found_obj, relation

        # Soft fallback
        if "what is" in q:
            return found_obj, "subclass of"

        return found_obj, None

    # -------------------------
    # ANSWER
    # -------------------------
    def answer(self, question):
        obj, relation = self.classify(question)

        # IMPORTANT: return None for hybrid fallback
        if not obj or not relation:
            return None

        if obj not in self.kg or relation not in self.kg[obj]:
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
    qa = RegexKGBasedQA(KG_FOLDER)

    print("\n=== CLASS-BASED REGEX QA ===")
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