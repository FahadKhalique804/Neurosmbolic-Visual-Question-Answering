from nltk import word_tokenize, pos_tag
from Controllers.AnswerFunctions import (
    handle_counting_question,
    handle_simple_presence_question,
    handle_scene_relation_question,
    handle_descriptive_question,
    categorize_question
)
from collections import defaultdict


class AnswerHandler:
    def __init__(self, cfg_model):
        self.cfg_model = cfg_model

    def generate_answer(self, question, detected_objects, scene_matrix):
        print("In generate_answer   ")
        print("question: ", question    )
        print("detected_objects: ", detected_objects)
        print("scene_matrix: ", scene_matrix)
        tokens = word_tokenize(question.lower())
        tagged = pos_tag(tokens)
        pos_sequence = ' '.join(tag for _, tag in tagged)

        print("tokens ", tokens)
        print("Tagged" , tagged)
        print("posSequence",pos_sequence)
        # CFG validation from DB
        if not self.cfg_model.rule_exists(pos_sequence):
            return " This question does not match any known CFG template."

        question_type = categorize_question([tag for _, tag in tagged], question.lower())
        nouns = [word for word, tag in tagged if tag.startswith("NN")]

        print(question_type)
        print(nouns)
        # Group detections
        grouped = defaultdict(list)
        labels = []
        for obj in detected_objects:
            label = obj['label']
            grouped[label].append(obj)
            labels.append(label)

        # Template placeholders (can be extended)
        if question_type == "counting":
            return handle_counting_question(nouns, grouped, "There are COUNT NNS.")
        elif question_type == "assertive":
            if any(p in question.lower() for p in ["left", "right", "behind", "front"]):
                return handle_scene_relation_question(nouns, labels, scene_matrix, "Yes/No, something is/is not REL NN.")
            else:
                return handle_simple_presence_question(nouns, labels, "Yes, there is a NN.")
        elif question_type == "descriptive":
            return handle_descriptive_question(nouns, grouped, "The NN is PROPERTY.")

        return " Unsupported question type."