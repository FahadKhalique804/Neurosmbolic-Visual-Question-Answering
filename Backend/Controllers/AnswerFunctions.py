def handle_counting_question(nouns, detected_labels, answer_template):
    for noun in nouns:
        noun_lower = noun.lower()
        singular_noun = noun_lower.rstrip('s')
        plural_noun = singular_noun + 's'

        for label in detected_labels:
            if label.lower() in [noun_lower, singular_noun, plural_noun]:
                count = len(detected_labels[label])

                if count == 1:
                    answer = answer_template.replace("COUNT", "one").replace("NNS", singular_noun).replace("NN", singular_noun)
                else:
                    answer = answer_template.replace("COUNT", str(count)).replace("NNS", plural_noun).replace("NN", plural_noun)

                print(f"Answer ➔ {answer}")
                return answer

    print("Answer ➔ I couldn't find the object in the image to count.")
    return "I couldn't find the object in the image to count."


def handle_simple_presence_question(nouns, labels, answer_template):
    for noun in nouns:
        for label in labels:
            if noun.lower() in [label.lower(), label.lower().rstrip('s')]:
                answer = f"Yes, there is a {label}"
                print(f"Answer ➔ {answer}")
                return answer

    label = nouns[0] if nouns else "object"
    answer = f"No, there is no {label}"
    print(f"Answer ➔ {answer}")
    return answer


def handle_scene_relation_question(nouns, labels, scene_matrix, answer_template):
    print("Nouns extracted:", nouns)
    prepositions = ["left", "right", "front", "behind"]
    detected_prep = next((p for p in prepositions if p in nouns), None)
    if not detected_prep:
        return "No spatial relation found."

    target = nouns[-1]
    relation_phrase = "in front of" if detected_prep == "front" else f"{detected_prep} of"

    target_idx = next((i for i, lbl in enumerate(labels) if target.lower() in {lbl.lower(), lbl.lower().rstrip('s')}), -1)
    if target_idx == -1:
        return f"Target noun '{target}' not found in scene."

    for i, label in enumerate(labels):
        if i != target_idx and scene_matrix[i][target_idx] == relation_phrase:
            answer = answer_template.replace("NN", target).replace("Yes/No", "Yes").replace("is not", "is")
            print(f"Answer ➔ {answer}")
            return answer

    answer = answer_template.replace("NN", target).replace("Yes/No", "No").replace("is", "is not")
    print(f"Answer ➔ {answer}")
    return answer


def handle_descriptive_question(nouns, detected_labels, answer_template):
    obj_noun = nouns[-1] if nouns else None
    matched_obj = None
    for label in detected_labels:
        if obj_noun and obj_noun.lower() in [label.lower(), label.lower().rstrip('s')]:
            matched_obj = label
            break

    if not matched_obj:
        return "I can't find that object in the image."

    obj_data = detected_labels[matched_obj][0]  # Take first occurrence
    property_noun = nouns[0].lower() if len(nouns) > 1 else None

    if property_noun == "shape":
        answer = f"The shape of the {matched_obj} is {obj_data.get('shape', 'unknown')}"
    elif property_noun == "color":
        answer = f"The color of the {matched_obj} is {obj_data.get('color', 'unknown')}"
    else:
        answer = answer_template.replace("NN", matched_obj)

    print(f"Answer ➔ {answer}")
    return answer


def categorize_question(pos_tags, question_text):
    question_text = question_text.lower()
    if "how many" in question_text:
        return "counting"
    elif pos_tags and pos_tags[0] in ["VBZ", "VBP"]:
        return "assertive"
    elif pos_tags and pos_tags[0] in ["WP", "WRB"]:
        return "descriptive"
    return "unknown"
