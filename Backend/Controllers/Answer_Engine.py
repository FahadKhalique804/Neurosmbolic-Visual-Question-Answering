from Controllers.CFG_Answer import CFGKGBasedQA
from Controllers.Regex_Answer import RegexKGBasedQA
from Controllers.ML_Answer import MLKGBasedQA


# -------------------------
# HYBRID QA ENGINE
# -------------------------
class HybridKGBasedQA:
    def __init__(self, kg_folder):
        self.cfg = CFGKGBasedQA(kg_folder)
        self.regex = RegexKGBasedQA(kg_folder)
        self.ml = MLKGBasedQA(kg_folder)

    def answer(self, question):
        # 1️⃣ CFG (most precise)
        ans = self.cfg.answer(question)
        if ans:
            print("[CFG]")
            return ans

        # 2️⃣ REGEX (pattern-based)
        ans = self.regex.answer(question)
        if ans:
            print("[REGEX]")
            return ans

        # 3️⃣ ML (probabilistic)
        ans = self.ml.answer(question)
        if ans:
            print("[ML]")
            return ans

        # ❌ FINAL FALLBACK
        return "Question is incorrect!"

    def speak(self, text):
        # use CFG TTS (any one is fine)
        self.cfg.speak(text)


# -------------------------
# MAIN LOOP
# -------------------------
if __name__ == "__main__":
    KG_FOLDER = r"D:\PyCharm Project\NS_VQA\Controllers\KnowledgeGraphs"

    qa = HybridKGBasedQA(KG_FOLDER)

    print("\n=== HYBRID KG-BASED QA SYSTEM ===")
    print("Flow: CFG → REGEX → ML")
    print("Type 'exit' to quit\n")

    while True:
        q = input("Q: ")
        if q.lower() == "exit":
            break

        answer = qa.answer(q)
        print("A:", answer)
        qa.speak(answer)