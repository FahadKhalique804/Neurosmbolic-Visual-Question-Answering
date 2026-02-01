import nltk
from Models.cfg_models import CFGModel


class NLPHandler:
    def __init__(self):
        self.cfg_model = CFGModel()
        self.valid_shapes = ['shape', 'circle', 'square', 'triangle']
        self.valid_colors = ['color', 'red', 'blue', 'green', 'yellow']
        self.valid_objects = ['object', 'ball', 'box', 'apple', 'dog']

    def validate_question(self, question, detected_objects):
        print("Detected Objects:", detected_objects)
        print("Question by User:", question)

        tokens = nltk.word_tokenize(question.lower())
        tagged = nltk.pos_tag(tokens)
        pos_sequence = ' '.join(tag for _, tag in tagged)

        print("Tagged:", tagged)
        print("POS Sequence:", pos_sequence)

        if not self.cfg_model.rule_exists(pos_sequence):
            print("❌ CFG rule not found.")
            return "Invalid: CFG rule not found"

        all_valid = True
        for word, tag in tagged:
            if tag == 'NN':
                # Check if NN is either in detected_objects or in vocabulary
                if word not in detected_objects and not self.cfg_model.vocab_exists(tag, word):
                    print(f"❌ NN '{word}' not in detected objects or vocabulary.")
                    all_valid = False
            else:
                if not self.cfg_model.vocab_exists(tag, word):
                    print(f"❌ Word '{word}' with POS '{tag}' not found in vocabulary.")
                    all_valid = False

        if all_valid:
            print("✅ VALID: CFG rule and all words match.")
            return "Valid"
        else:
            print("⚠️ CFG rule matches, but some words do not.")
            return "NOT VALID"

    def add_rule_from_question(self, question):
        tokens = nltk.word_tokenize(question.lower())
        tagged = nltk.pos_tag(tokens)
        pos_sequence = ' '.join(tag for _, tag in tagged)

        if self.cfg_model.rule_exists(pos_sequence):
            print("⚠️ Rule already exists.")
            return

        self.cfg_model.insert_rule('S', pos_sequence)
        print("✅ Rule inserted.")

        for word, tag in tagged:
            if not self.cfg_model.vocab_exists(tag, word):
                self.cfg_model.insert_vocab(tag, word)
                print(f"✅ Added to vocabulary: ({tag}, '{word}')")
            else:
                print(f"✔️ Vocabulary exists: ({tag}, '{word}')")

    def update_rule_by_questions(self, old_q, new_q):
        old_rhs = ' '.join(tag for _, tag in nltk.pos_tag(nltk.word_tokenize(old_q.lower())))
        new_tokens = nltk.word_tokenize(new_q.lower())
        new_tagged = nltk.pos_tag(new_tokens)
        new_rhs = ' '.join(tag for _, tag in new_tagged)

        result = self.cfg_model.find_rule_by_rhs(old_rhs)
        if not result:
            print("❌ Rule not found to update.")
            return

        rule_id = result[0]
        self.cfg_model.update_rule(rule_id, new_rhs)
        print(f"✅ Rule updated to: {new_rhs}")

        for word, tag in new_tagged:
            if not self.cfg_model.vocab_exists(tag, word):
                self.cfg_model.insert_vocab(tag, word)
                print(f"✅ Added vocabulary: ({tag}, '{word}')")

    def get_pos_tags(self, question):
        tokens = nltk.word_tokenize(question.lower())
        tagged = nltk.pos_tag(tokens)
        return [{'word': word, 'pos': tag} for word, tag in tagged]
