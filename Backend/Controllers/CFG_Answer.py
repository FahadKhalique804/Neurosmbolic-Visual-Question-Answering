import os
import json
import sys

# Try importing pyttsx3
try:
    import pyttsx3
    TTS_AVAILABLE = True
except ImportError:
    TTS_AVAILABLE = False

# Try importing nltk
try:
    import nltk
    from nltk import CFG
except ImportError:
    print("Error: nltk is required. Install via pip install nltk")
    sys.exit(1)


class CFGKGBasedQA:
    def __init__(self, kg_folder):
        self.kg_folder = kg_folder
        self.kg = self.load_kg()
        self.objects = list(self.kg.keys()) or ["dummy_object"]
        self.engine = pyttsx3.init() if TTS_AVAILABLE else None

        self.relation_map = {
            "UsedForQ": "used for",
            "HasPartQ": "has part",
            "PartOfQ": "part of",
            "MaterialQ": "material used",
            "SubclassQ": "subclass of",
            "LifespanQ": "lifespan",
            "WeightQ": "weight",
            "HeightQ": "height",
            "ManufacturerQ": "manufacturer",
            "ColorQ": "color"
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

        self.parser = self.build_parser()

    # -------------------------
    # TTS
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
            if file.endswith(".json"):
                with open(os.path.join(self.kg_folder, file), "r", encoding="utf-8") as f:
                    data = json.load(f)

                obj = data["object"].lower()
                kg[obj] = {}

                for _, relation, value in data["triplets"]:
                    kg[obj].setdefault(relation.lower(), []).append(value)

        return kg

    # -------------------------
    # GRAMMAR HELPERS
    # -------------------------
    def format_object(self, obj):
        return " ".join(f'"{p}"' for p in obj.split())

    def build_parser(self):
        object_rules = " | ".join(self.format_object(o) for o in self.objects)

        grammar_string = f"""
        S -> SubclassQ | PartOfQ | UsedForQ | HasPartQ | LifespanQ | HeightQ | WeightQ | ManufacturerQ | ColorQ
        Det -> "a" | "an" | "the"

        SubclassQ -> "what" "is" Det Object "?" | "define" Det Object "?"
        PartOfQ -> "which" "system" "does" Det Object "belong" "to" "?" | Det Object "is" "part" "of" "?"
        UsedForQ -> "what" "is" "the" "purpose" "of" Det Object "?" | "what" "does" Det Object "do" "?"
        HasPartQ -> "what" "parts" "does" Det Object "have" "?"
        LifespanQ -> "how" "long" "does" Det Object "last" "?"
        HeightQ -> "how" "tall" "is" Det Object "?"
        WeightQ -> "how" "heavy" "is" Det Object "?"
        ManufacturerQ -> "who" "makes" Det Object "?"
        ColorQ -> "what" "color" "is" Det Object "?"

        Object -> {object_rules}
        """

        grammar = CFG.fromstring(grammar_string)
        return nltk.ChartParser(grammar)

    # -------------------------
    # CFG CLASSIFICATION
    # -------------------------
    def classify(self, question):
        words = question.lower().replace("?", " ?").split()

        try:
            for tree in self.parser.parse(words):
                rule = tree[0].label()
                relation = self.relation_map.get(rule)

                for subtree in tree.subtrees(lambda t: t.label() == "Object"):
                    obj = " ".join(subtree.leaves())
                    return obj, relation
        except:
            pass

        return None, None

    # -------------------------
    # ANSWER
    # -------------------------
    def answer(self, question):
        obj, relation = self.classify(question)

        if not obj or not relation:
            return None  # IMPORTANT: return None for hybrid fallback

        if obj not in self.kg or relation not in self.kg[obj]:
            return None

        value = ", ".join(self.kg[obj][relation])
        template = self.templates.get(relation)

        return template.format(object=obj.capitalize(), value=value)

if __name__ == "__main__":
    KG_FOLDER = r"D:\PyCharm Project\NS_VQA\Controllers\KnowledgeGraphs"
    qa = CFGKGBasedQA(KG_FOLDER)

    print("\n=== CLASS-BASED CFG QA ===")
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