from flask import Blueprint, request, jsonify
from Controllers.NlpHandler import NLPHandler

nlp_routes = Blueprint("nlp_routes", __name__)
nlp = NLPHandler()
detected_objects = ['dog', 'shape', 'color']


@nlp_routes.route('/validate', methods=['POST'])
def validate():
    data = request.get_json(force=True)
    question = data["question"]
    result = nlp.validate_question(question, detected_objects)
    return jsonify({"message": result})


@nlp_routes.route('/get-pos-tags', methods=['POST'])
def get_pos_tags():
    data = request.get_json(force=True)
    question = data["question"]
    alltags = nlp.get_pos_tags(question)
    pos_tags = [item["pos"] for item in alltags]
    pos_sequence = ' '.join(pos_tags)

    return jsonify(
        {
            "PosTags": alltags,
            "Rule": pos_sequence
        })


@nlp_routes.route('/add-rule', methods=['POST'])
def add_rule():
    data = request.get_json(force=True)
    question = data["question"]
    nlp.add_rule_from_question(question)
    return jsonify({"message": "Rule processing completed."})


@nlp_routes.route('/update-rule', methods=['PUT'])
def update_rule():
    old_question = request.form.get("old_question")
    new_question = request.form.get("new_question")
    nlp.update_rule_by_questions(old_question, new_question)
    return jsonify({"message": "Rule update completed."})


@nlp_routes.route('/get-vocabulary', methods=['GET'])
def get_vocabulary():
    vocab = nlp.cfg_model.get_all_vocabulary()
    vocab_list = [{"pos_tag": tag, "word": word} for tag, word in vocab]
    return jsonify(vocab_list)


@nlp_routes.route('/get-rules', methods=['GET'])
def get_rules():
    rules = nlp.cfg_model.get_all_rules()
    rule_list = [{"id": r[0], "lhs": r[1], "rhs": r[2]} for r in rules]
    return jsonify(rule_list)


@nlp_routes.route('/delete-rule/<int:rule_id>', methods=['DELETE'])
def delete_rule(rule_id):
    try:
        nlp.cfg_model.delete_rule(rule_id)
        return jsonify({"message": f"🗑️ Rule ID {rule_id} deleted."})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@nlp_routes.route('/delete-vocabulary', methods=['DELETE'])
def delete_vocabulary():
    pos_tag = request.form.get("pos_tag")
    word = request.form.get("word")

    if not pos_tag or not word:
        return jsonify({"error": "Both 'pos_tag' and 'word' are required."}), 400

    try:
        nlp.cfg_model.delete_vocab(pos_tag, word)
        return jsonify({"message": f"🗑️ Deleted vocabulary: ({pos_tag}, '{word}')"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@nlp_routes.route('/add-vocabulary', methods=['POST'])
def add_vocabulary():
    data = request.get_json(force=True)
    pos_tag = data["posTag"]
    word = data["word"]
    if not pos_tag or not word:
        return jsonify({"message": "Both 'pos_tag' and 'word' are required."}), 400

    try:
        if nlp.cfg_model.vocab_exists(pos_tag, word):
            return jsonify({"message": f"Vocabulary ({pos_tag}, '{word}') already exists."}), 400

        nlp.cfg_model.insert_vocab(pos_tag, word)
        return jsonify({"message": "Saved"})

    except Exception as e:
        return jsonify({"message": str(e)}), 500