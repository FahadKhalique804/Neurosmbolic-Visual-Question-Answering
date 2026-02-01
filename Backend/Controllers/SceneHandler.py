# import re
#
# class SceneHandler:
#     RELATIONS = ["left of", "right of", "above", "below", "near"]
#
#     def __init__(self, objects, scene_graph, properties):
#         self.objects = objects
#         self.scene_graph = scene_graph
#         self.properties = {obj: prop for obj, prop in zip(objects, properties)}
#
#         # print("\n===== Scene Graph Triplets =====")
#         # for rel in self.scene_graph:
#         #     print(f"{rel['from']} ---[{rel['relation']}]---> {rel['to']}")
#         #
#         # print("\n===== Object Properties =====")
#         # for obj in self.objects:
#         #     prop = self.properties.get(obj, {})
#         #     print(f"Object: {prop.get('label', obj)}")
#         #     print(f"  BBox: {prop.get('bbox', [])}")
#         #     print(f"  Color: {prop.get('color', 'unknown')}")
#         #     print(f"  Shape: {prop.get('shape', 'unknown')}")
#         #     print(f"  Emotion: {prop.get('emotion', 'not_applicable')}")
#         #     print("-" * 40)
#         # Regexes
#         self.relation_regex = self._compile_relation_regex()
#         self.property_regex = self._compile_properties_regex()
#         self.object_check_regex = re.compile(r"^is there a (?P<obj>[\w]+)\?$", re.IGNORECASE)
#
#         self.summary_questions = {
#             "what is in front of me?": self._answer_in_front,
#             "tell me how many objects are present?": self._answer_count_objects,
#             "can you tell me what objects are here?": self._answer_list_objects
#         }
#
#     # ---------------- Relation Regex ----------------
#     def _compile_relation_regex(self):
#         rel_pattern = "|".join(map(re.escape, self.RELATIONS))
#         obj_pattern = r"[\w]+"
#         pattern_exist = (
#             rf"(?P<existence>"
#             rf"is\s+(there\s+)?anything\s+(?P<rel1>{rel_pattern})\s+(?P<obj1>{obj_pattern})\?"
#             rf")"
#         )
#         pattern_count = (
#             rf"(?P<count>"
#             rf"how\s+many\s+objects\s+(?P<rel2>{rel_pattern})\s+(?P<obj2>{obj_pattern})\?"
#             rf")"
#         )
#         final_pattern = rf"^({pattern_exist}|{pattern_count})$"
#         return re.compile(final_pattern, re.IGNORECASE)
#
#     # ---------------- Property Regex ----------------
#     def _compile_properties_regex(self):
#         pattern1 = r"Tell me (?P<prop1>[\w]+) of (?P<obj1>[\w]+)\?"
#         pattern2 = r"What is the (?P<prop2>[\w]+) of (?P<obj2>[\w]+)\?"
#         final_pattern = rf"^({pattern1}|{pattern2})$"
#         return re.compile(final_pattern, re.IGNORECASE)
#
#     # ---------------- Object Resolver ----------------
#     def _resolve_object(self, obj_name):
#         exact_match = [o for o in self.objects if o.lower() == obj_name.lower()]
#         if exact_match:
#             return exact_match[0]
#         prefix_matches = [o for o in self.objects if o.lower().startswith(obj_name.lower())]
#         if len(prefix_matches) == 1:
#             return prefix_matches[0]
#         return None
#
#     # ---------------- Summary Answers ----------------
#     def _answer_in_front(self):
#         return f"The objects in front are: {', '.join(self.objects)}."
#
#     def _answer_count_objects(self):
#         return f"There are {len(self.objects)} objects present."
#
#     def _answer_list_objects(self):
#         return f"The objects present are: {', '.join(self.objects)}."
#
#     # ---------------- Ask Method ----------------
#     def ask(self, question):
#         q_lower = question.lower()
#
#         # ---------------- Scene Summary ----------------
#         if q_lower in self.summary_questions:
#             return self.summary_questions[q_lower]()
#
#         # ---------------- Object Existence ----------------
#         match_obj_check = self.object_check_regex.match(question)
#         if match_obj_check:
#             obj_name = match_obj_check.group("obj")
#             obj = self._resolve_object(obj_name)
#             return f"Yes, {obj} is present." if obj else f"No, {obj_name} is not present."
#
#         # ---------------- Relation Questions ----------------
#         match_rel = self.relation_regex.match(question)
#         if match_rel:
#             if match_rel.group("existence"):
#                 relation = match_rel.group("rel1")
#                 obj_name = match_rel.group("obj1")
#                 is_count = False
#             else:
#                 relation = match_rel.group("rel2")
#                 obj_name = match_rel.group("obj2")
#                 is_count = True
#
#             obj = self._resolve_object(obj_name)
#             if not obj:
#                 return f"❌ Object {obj_name} not present"
#
#             matches = [edge['from'] for edge in self.scene_graph
#                        if edge['relation'].lower() == relation.lower() and edge['to'].lower() == obj.lower()]
#
#             if is_count:
#                 return f"There are {len(matches)} objects {relation} {obj}."
#             else:
#                 if matches:
#                     return f"Yes, {', '.join(matches)} is/are {relation} {obj}."
#                 else:
#                     return f"No objects are {relation} {obj}."
#
#         # ---------------- Property Questions ----------------
#         match_prop = self.property_regex.match(question)
#         if match_prop:
#             prop_name = match_prop.group("prop1") or match_prop.group("prop2")
#             obj_name = match_prop.group("obj1") or match_prop.group("obj2")
#
#             obj = self._resolve_object(obj_name)
#             if not obj:
#                 return f"❌ Object {obj_name} not present"
#
#             value = self.properties[obj].get(prop_name)
#             if value is None:
#                 return f"❌ Property '{prop_name}' not present for {obj}."
#             return f"The {prop_name} of {obj} is {value}."
#
#         # ---------------- Unknown Format ----------------
#         return "❌ Invalid question format."
#
#
# # # ---------------- TEST ----------------
# # objects = ['Person', 'Tie', 'cat']
# # scene_graph = [
# #     {'from': 'Person', 'relation': 'right of', 'to': 'cat'},
# #     {'from': 'cat', 'relation': 'right of', 'to': 'Person'}
# # ]
# # properties = [
# #     {'color': 'darkgray', 'emotion': 'angry', 'label': 'Person', 'shape': 'square'},
# #     {'color': 'blue', 'emotion': 'not_applicable', 'label': 'Tie', 'shape': 'rectangle'},
# #     {'color': 'black', 'emotion': 'not_applicable', 'label': 'cat', 'shape': 'tall'}
# # ]
#
# # handler = SceneHandler(objects, scene_graph, properties)
#
# # tests = [
# #     "what is in front of me?",
# #     "tell me how many objects are present?",
# #     "can you tell me what objects are here?",
# #     "Tell me color of Person?",
# #     "What is the emotion of Tie?",
# #     "is there anything right of cat?",
# #     "how many objects right of Person?",
# #     "is there a Person?",
# #     "is there a Dog?",
# #     "is there a cat?",
# # ]
# #
# # for t in tests:
# #     print(t, "➡️", handler.ask(t))
#
#
# # while True:
# #     question = input("Ask a question (or type 'exit' to quit): ").strip()
# #     if question.lower() in ["exit", "quit"]:
# #         print("Exiting. Goodbye!")
# #         break
# #     answer = handler.ask(question)
# #     print("➡️", answer)


# #Type 2
# import pprint
# import re
#
# class SceneHandler:
#     RELATIONS = ["left of", "right of", "above", "below", "near"]
#
#     def __init__(self, objects, scene_graph, properties):
#         self.objects = objects
#         self.scene_graph = scene_graph
#         self.properties = {obj: prop for obj, prop in zip(objects, properties)}
#
#         # print("\n===== Scene Graph Triplets =====")
#         # for rel in self.scene_graph:
#         #     print(f"{rel['from']} ---[{rel['relation']}]---> {rel['to']}")
#         #
#         # print("\n===== Object Properties =====")
#         # for obj in self.objects:
#         #     prop = self.properties.get(obj, {})
#         #     print(f"Object: {prop.get('label', obj)}")
#         #     print(f"  BBox: {prop.get('bbox', [])}")
#         #     print(f"  Color: {prop.get('color', 'unknown')}")
#         #     print(f"  Shape: {prop.get('shape', 'unknown')}")
#         #     print(f"  Emotion: {prop.get('emotion', 'not_applicable')}")
#         #     print("-" * 40)
#         # Regexes
#         self.relation_regex = self._compile_relation_regex()
#         self.property_regex = self._compile_properties_regex()
#         self.object_check_regex = re.compile(r"^is there a (?P<obj>[\w]+)\?$", re.IGNORECASE)
#
#         self.summary_questions = {
#             "what is in front of me?": self._answer_in_front,
#             "tell me how many objects are present?": self._answer_count_objects,
#             "can you tell me what objects are here?": self._answer_list_objects
#         }
#
#     # ---------------- Relation Regex ----------------
#     def _compile_relation_regex(self):
#         rel_pattern = "|".join(map(re.escape, self.RELATIONS))
#         obj_pattern = r"[\w]+"
#         pattern_exist = (
#             rf"(?P<existence>"
#             rf"is\s+(there\s+)?anything\s+(?P<rel1>{rel_pattern})\s+(?P<obj1>{obj_pattern})\?"
#             rf")"
#         )
#         pattern_count = (
#             rf"(?P<count>"
#             rf"how\s+many\s+objects\s+(?P<rel2>{rel_pattern})\s+(?P<obj2>{obj_pattern})\?"
#             rf")"
#         )
#         final_pattern = rf"^({pattern_exist}|{pattern_count})$"
#         return re.compile(final_pattern, re.IGNORECASE)
#
#     # ---------------- Property Regex ----------------
#     def _compile_properties_regex(self):
#         pattern1 = r"Tell me (?P<prop1>[\w]+) of (?P<obj1>[\w]+)\?"
#         pattern2 = r"What is the (?P<prop2>[\w]+) of (?P<obj2>[\w]+)\?"
#         final_pattern = rf"^({pattern1}|{pattern2})$"
#         return re.compile(final_pattern, re.IGNORECASE)
#
#     # ---------------- Object Resolver ----------------
#     def _resolve_object(self, obj_name):
#         exact_match = [o for o in self.objects if o.lower() == obj_name.lower()]
#         if exact_match:
#             return exact_match[0]
#         prefix_matches = [o for o in self.objects if o.lower().startswith(obj_name.lower())]
#         if len(prefix_matches) == 1:
#             return prefix_matches[0]
#         return None
#
#     # ---------------- Summary Answers ----------------
#     def _answer_in_front(self):
#         return f"The objects in front are: {', '.join(self.objects)}."
#
#     def _answer_count_objects(self):
#         return f"There are {len(self.objects)} objects present."
#
#     def _answer_list_objects(self):
#         return f"The objects present are: {', '.join(self.objects)}."
#
#     # ---------------- Ask Method ----------------
#     def ask(self, question):
#         q_lower = question.lower()
#
#         # ---------------- Scene Summary ----------------
#         if q_lower in self.summary_questions:
#             return self.summary_questions[q_lower]()
#
#         # ---------------- Object Existence ----------------
#         match_obj_check = self.object_check_regex.match(question)
#         if match_obj_check:
#             obj_name = match_obj_check.group("obj")
#             obj = self._resolve_object(obj_name)
#             return f"Yes, {obj} is present." if obj else f"No, {obj_name} is not present."
#
#         # ---------------- Relation Questions ----------------
#         match_rel = self.relation_regex.match(question)
#         if match_rel:
#             if match_rel.group("existence"):
#                 relation = match_rel.group("rel1")
#                 obj_name = match_rel.group("obj1")
#                 is_count = False
#             else:
#                 relation = match_rel.group("rel2")
#                 obj_name = match_rel.group("obj2")
#                 is_count = True
#
#             obj = self._resolve_object(obj_name)
#             if not obj:
#                 return f"❌ Object {obj_name} not present"
#
#             matches = [edge['from'] for edge in self.scene_graph
#                        if edge['relation'].lower() == relation.lower() and edge['to'].lower() == obj.lower()]
#
#             if is_count:
#                 return f"There are {len(matches)} objects {relation} {obj}."
#             else:
#                 if matches:
#                     return f"Yes, {', '.join(matches)} is/are {relation} {obj}."
#                 else:
#                     return f"No objects are {relation} {obj}."
#
#         # ---------------- Property Questions ----------------
#         match_prop = self.property_regex.match(question)
#         if match_prop:
#             prop_name = match_prop.group("prop1") or match_prop.group("prop2")
#             obj_name = match_prop.group("obj1") or match_prop.group("obj2")
#
#             obj = self._resolve_object(obj_name)
#             if not obj:
#                 return f"❌ Object {obj_name} not present"
#
#             value = self.properties[obj].get(prop_name)
#             if value is None:
#                 return None
#
#             return f"The {prop_name} of {obj} is {value}."
#
#         # ---------------- Unknown Format ----------------
#         return None
#
#     def debug(self):
#         pp = pprint.PrettyPrinter(indent=4)
#
#         print("\n--- OBJECTS ---")
#         pp.pprint(self.objects)
#
#         print("\n--- SCENE GRAPH ---")
#         pp.pprint(self.scene_graph)
#
#         print("\n--- PROPERTIES ---")
#         pp.pprint(self.properties)
#



# #New 1
# import re
# import pprint
#
#
# class SceneHandler:
#     RELATIONS = ["left of", "right of", "above", "below", "near"]
#
#     def __init__(self, objects, scene_graph, properties):
#         self.objects = objects
#         self.scene_graph = scene_graph
#         self.properties = {obj: prop for obj, prop in zip(objects, properties)}
#
#         # print("\n===== Scene Graph Triplets =====")
#         # for rel in self.scene_graph:
#         #     print(f"{rel['from']} ---[{rel['relation']}]---> {rel['to']}")
#         #
#         # print("\n===== Object Properties =====")
#         # for obj in self.objects:
#         #     prop = self.properties.get(obj, {})
#         #     print(f"Object: {prop.get('label', obj)}")
#         #     print(f"  BBox: {prop.get('bbox', [])}")
#         #     print(f"  Color: {prop.get('color', 'unknown')}")
#         #     print(f"  Shape: {prop.get('shape', 'unknown')}")
#         #     print(f"  Emotion: {prop.get('emotion', 'not_applicable')}")
#         #     print("-" * 40)
#         # Regexes
#         self.relation_regex = self._compile_relation_regex()
#         self.property_regex = self._compile_properties_regex()
#         self.object_check_regex = re.compile(r"^is there a (?P<obj>[\w]+)\?$", re.IGNORECASE)
#
#         self.summary_questions = {
#             "what is in front of me?": self._answer_in_front,
#             "tell me how many objects are present?": self._answer_count_objects,
#             "can you tell me what objects are here?": self._answer_list_objects
#         }
#
#         # self.presence_regex = re.compile(
#         #     r"^tell me if (?P<obj>[\w]+)(?: in center)?\s+(?P<action>leaves?|left|comes?|enters?)\s+(the\s+room)?\.?$",
#         #     re.IGNORECASE
#         # )
#
#         self.presence_regex = re.compile(
#             r"""^tell\s+me\s+if\s+
#                 (?P<obj>\w+)
#                 (?:\s+in\s+center)?
#                 \s+(?P<action>leave|leaves|left|come|comes|enter|enters)
#                 (?:\s+the\s+room)?
#                 \s*[\?\.\!]?$
#             """,
#             re.IGNORECASE | re.VERBOSE
#         )
#
#         self.PRONOUN_MAP = {
#             "he": "person",
#             "she": "person",
#             "him": "person",
#             "her": "person",
#             "they": "person",
#             "them": "person"
#         }
#
#     def debug(self):
#         pp = pprint.PrettyPrinter(indent=4)
#
#         print("\n--- OBJECTS ---")
#         pp.pprint(self.objects)
#
#         print("\n--- SCENE GRAPH ---")
#         pp.pprint(self.scene_graph)
#
#         print("\n--- PROPERTIES ---")
#         pp.pprint(self.properties)
#
#     # ---------------- Relation Regex ----------------
#     def _compile_relation_regex(self):
#         rel_pattern = "|".join(map(re.escape, self.RELATIONS))
#         obj_pattern = r"[\w]+"
#         pattern_exist = (
#             rf"(?P<existence>"
#             rf"is\s+(there\s+)?anything\s+(?P<rel1>{rel_pattern})\s+(?P<obj1>{obj_pattern})\?"
#             rf")"
#         )
#         pattern_count = (
#             rf"(?P<count>"
#             rf"how\s+many\s+objects\s+(?P<rel2>{rel_pattern})\s+(?P<obj2>{obj_pattern})\?"
#             rf")"
#         )
#         final_pattern = rf"^({pattern_exist}|{pattern_count})$"
#
#         return re.compile(final_pattern, re.IGNORECASE)
#
#     # def _answer_presence(self, obj_name, action):
#     #     obj = self._resolve_object(obj_name)
#     #
#     #     if obj:
#     #         return f"{obj} is present now."
#     #     else:
#     #         return f"{obj_name} leaves the room"
#
#     def _answer_presence(self, obj_name, action):
#         action = action.lower()
#         obj = self._resolve_object(obj_name)
#
#         # -------- ENTER CASE --------
#         if action in {"come", "comes", "enter", "enters"}:
#             if obj:
#                 return f"Yes the {obj_name} has entered"
#             else:
#                 return f"No, {obj_name} is not entered right now"
#
#         # -------- EXIT CASE --------
#         if action in {"leave", "leaves", "left"}:
#             if obj:
#                 return f"No, the {obj_name} is still inside the room."
#             else:
#                 return f"Yes, the {obj_name} has left the room."
#
#         return "I couldn't determine the movement clearly."
#
#     # ---------------- Property Regex ----------------
#     def _compile_properties_regex(self):
#         pattern1 = r"Tell me (?P<prop1>[\w]+) of (?P<obj1>[\w]+)\?"
#         pattern2 = r"What is the (?P<prop2>[\w]+) of (?P<obj2>[\w]+)\?"
#         final_pattern = rf"^({pattern1}|{pattern2})$"
#         return re.compile(final_pattern, re.IGNORECASE)
#
#     # ---------------- Object Resolver ----------------
#     def _resolve_object(self, obj_name):
#         exact_match = [o for o in self.objects if o.lower() == obj_name.lower()]
#         if exact_match:
#             return exact_match[0]
#         prefix_matches = [o for o in self.objects if o.lower().startswith(obj_name.lower())]
#         if len(prefix_matches) == 1:
#             return prefix_matches[0]
#         return None
#
#     # ---------------- Summary Answers ----------------
#     # def _answer_in_front(self):
#     #     return f"The objects in front are: {', '.join(self.objects)}."
#
#     def _answer_in_front(self):
#         if not self.objects:
#             return "No objects detected."
#         from collections import Counter
#         counts = Counter(self.objects)
#         parts = []
#         for obj, cnt in counts.items():
#             if cnt == 1:
#                 parts.append(f"1 {obj}")
#             else:
#                 # simple pluralization: add 's'
#                 parts.append(f"{cnt} {obj}s")
#         return "The objects in front are: " + ", ".join(parts) + "."
#
#     def _answer_count_objects(self):
#         return f"There are {len(self.objects)} objects present."
#
#     def _answer_list_objects(self):
#         return f"The objects present are: {', '.join(self.objects)}."
#
#     def resolve_pronoun(self, question):
#         words = question.lower().split()
#         resolved = []
#
#         for w in words:
#             if w in self.PRONOUN_MAP:
#                 resolved.append(self.PRONOUN_MAP[w])
#             else:
#                 resolved.append(w)
#
#         return " ".join(resolved)
#
#     # ---------------- Ask Method ----------------
#     def ask(self, question):
#         question = self.resolve_pronoun(question)
#         print("Question Recieved in Ask:", question)
#         q_lower = question.lower()
#
#         # ---------------- Scene Summary ----------------
#         if q_lower in self.summary_questions:
#             return self.summary_questions[q_lower]()
#
#         # ---------------- Object Existence ----------------
#         match_obj_check = self.object_check_regex.match(question)
#         if match_obj_check:
#             obj_name = match_obj_check.group("obj")
#             obj = self._resolve_object(obj_name)
#             return f"Yes, {obj} is present." if obj else f"No, {obj_name} is not present."
#
#         # ---------------- Presence / Movement Questions ----------------
#         print("DEBUG ask(): question=", question)
#         match_presence = self.presence_regex.match(question.strip())
#         print(match_presence)
#         if match_presence:
#             print("DEBUG match_presence:", match_presence.groupdict())
#             obj_name = match_presence.group("obj")
#             action = match_presence.group("action")
#             return self._answer_presence(obj_name, action)
#
#         # ---------------- Relation Questions ----------------
#         match_rel = self.relation_regex.match(question)
#         if match_rel:
#             if match_rel.group("existence"):
#                 relation = match_rel.group("rel1")
#                 obj_name = match_rel.group("obj1")
#                 is_count = False
#             else:
#                 relation = match_rel.group("rel2")
#                 obj_name = match_rel.group("obj2")
#                 is_count = True
#
#             obj = self._resolve_object(obj_name)
#             if not obj:
#                 return f"❌ Object {obj_name} not present"
#
#             matches = [edge['from'] for edge in self.scene_graph
#                        if edge['relation'].lower() == relation.lower() and edge['to'].lower() == obj.lower()]
#
#             if is_count:
#                 return f"There are {len(matches)} objects {relation} {obj}."
#             else:
#                 if matches:
#                     return f"Yes, {', '.join(matches)} is/are {relation} {obj}."
#                 else:
#                     return f"No objects are {relation} {obj}."
#
#         # ---------------- Property Questions ----------------
#         match_prop = self.property_regex.match(question)
#         if match_prop:
#             prop_name = match_prop.group("prop1") or match_prop.group("prop2")
#             obj_name = match_prop.group("obj1") or match_prop.group("obj2")
#
#             obj = self._resolve_object(obj_name)
#             if not obj:
#                 return f"❌ Object {obj_name} not present"
#
#             value = self.properties[obj].get(prop_name)
#
#             if value is None:
#                 return None
#             if prop_name.lower() == "emotion":
#                 if value in [None, "none", "not_applicable"]:
#                     return "Emotion is not applicable for this object."
#
#         # ---------------- Unknown Format ----------------
#         return None


#New 2
# from collections import Counter
# from Controllers.scene_questions import *
#
# PRONOUN_MAP = {
#     "he": "person",
#     "she": "person",
#     "him": "person",
#     "her": "person",
#     "they": "person",
#     "them": "person"
# }
#
# class SceneHandler:
#
#     def __init__(self, objects, scene_graph, properties):
#         self.objects = objects
#         self.scene_graph = scene_graph
#         self.properties = {o: p for o, p in zip(objects, properties)}
#
#     def debug(self):
#         import pprint
#         pp = pprint.PrettyPrinter(indent=4)
#
#         print("\n--- OBJECTS ---")
#         pp.pprint(self.objects)
#
#         print("\n--- SCENE GRAPH ---")
#         pp.pprint(self.scene_graph)
#
#         print("\n--- PROPERTIES ---")
#         pp.pprint(self.properties)
#     # ---------------- Counting Answers ----------------
#     def answer_count_specific(self, obj_name):
#         obj_name = obj_name.strip().lower()
#         matches = [
#             o for o in self.objects
#             if o.lower() == obj_name or o.lower().startswith(obj_name)
#         ]
#         return f"There are {len(matches)} {obj_name}(s)."
#
#     def answer_count_container(self, obj_name, container, prep):
#         obj_name = obj_name.strip().lower()
#         container = container.strip().lower()
#         if prep == "there in":
#             prep = "in"
#         matches = [
#             edge["from"]
#             for edge in self.scene_graph
#             if edge["relation"].lower() == prep
#             and edge["to"].lower() == container
#             and edge["from"].lower().startswith(obj_name)
#         ]
#         return f"There are {len(matches)} {obj_name}(s) {prep} the {container}."
#
#     # ---------------- Utilities ----------------
#     def resolve_pronouns(self, text):
#         return " ".join(PRONOUN_MAP.get(w, w) for w in text.lower().split())
#
#     def resolve_object(self, name):
#         exact = [o for o in self.objects if o.lower() == name.lower()]
#         if exact:
#             return exact[0]
#         prefix = [o for o in self.objects if o.lower().startswith(name.lower())]
#         return prefix[0] if len(prefix) == 1 else None
#
#     # ---------------- Summary ----------------
#     def answer_summary(self, q):
#         if "how many" in q:
#             return f"There are {len(self.objects)} objects present."
#         if "what objects" in q:
#             return f"The objects present are: {', '.join(self.objects)}."
#         counts = Counter(self.objects)
#         return "The objects in front are: " + ", ".join(
#             f"{v} {k}{'s' if v > 1 else ''}" for k, v in counts.items()
#         )
#
#     # ---------------- Movement ----------------
#     def answer_movement(self, obj_name, action):
#         obj = self.resolve_object(obj_name)
#         action = action.lower()
#         if action in {"come", "comes", "enter", "enters"}:
#             return f"Yes the {obj_name} has entered" if obj else f"No, {obj_name} is not entered right now"
#         if action in {"leave", "leaves", "left"}:
#             return f"No, the {obj_name} is still inside the room." if obj else f"Yes, the {obj_name} has left the room."
#
#     # ---------------- Relations ----------------
#     def answer_relation(self, relation, obj_name, count=False):
#         obj = self.resolve_object(obj_name)
#         if not obj:
#             return f"❌ Object {obj_name} not present"
#         matches = [
#             e["from"] for e in self.scene_graph
#             if e["relation"].lower() == relation.lower()
#             and e["to"].lower() == obj.lower()
#         ]
#         if count:
#             return f"There are {len(matches)} objects {relation} {obj}."
#         return f"Yes, {', '.join(matches)} is/are {relation} {obj}." if matches else f"No objects are {relation} {obj}."
#
#     # ---------------- Property ----------------
#     def answer_property(self, prop, obj_name):
#         obj = self.resolve_object(obj_name)
#         if not obj:
#             return f"❌ Object {obj_name} not present"
#         value = self.properties.get(obj, {}).get(prop)
#         if prop.lower() == "emotion":
#             if value in {None, "none", "not_applicable"}:
#                 return "Emotion is not applicable for this object."
#             return f"{obj} is {value}"
#         return value
#
#     # ---------------- Emotion Yes/No ----------------
#     def answer_emotion(self, obj_name, emotion):
#         obj = self.resolve_object(obj_name)
#         if not obj:
#             return f"❌ Object {obj_name} not present"
#         obj_emotion = self.properties.get(obj, {}).get("emotion")
#         if obj_emotion in {None, "none", "not_applicable"}:
#             return "Emotion is not applicable for this object."
#         return "Yes" if obj_emotion.lower() == emotion.lower() else "No"
#
#     # ---------------- Main Entry ----------------
#     def ask(self, question):
#         question = self.resolve_pronouns(question.strip().lower())
#
#         # ---------------- Summary ----------------
#         if question in SUMMARY_QUESTIONS:
#             return self.answer_summary(question)
#
#         # ---------------- Object existence ----------------
#         m = OBJECT_EXISTENCE_REGEX.match(question)
#         if m:
#             return f"Yes, {m.group('obj')} is present." if self.resolve_object(m.group("obj")) else f"No, {m.group('obj')} is not present."
#
#         m = OBJECT_EXISTENCE_ALT_REGEX.match(question)
#         if m:
#             return f"Yes, {m.group('obj')} is present." if self.resolve_object(m.group("obj")) else f"No, {m.group('obj')} is not present."
#
#         # ---------------- Counting ----------------
#         m = COUNT_SPECIFIC_REGEX.match(question)
#         if m:
#             return self.answer_count_specific(m.group("obj"))
#
#         m = COUNT_CONTAINER_REGEX.match(question)
#         if m:
#             return self.answer_count_container(m.group("obj"), m.group("container"), m.group("prep"))
#
#         # ---------------- Movement ----------------
#         m = MOVEMENT_REGEX.match(question)
#         if m:
#             return self.answer_movement(m.group("obj"), m.group("action"))
#
#         # ---------------- Relations ----------------
#         m = RELATION_REGEX.match(question)
#         if m:
#             if m.group("rel1"):
#                 return self.answer_relation(m.group("rel1"), m.group("obj1"))
#             return self.answer_relation(m.group("rel2"), m.group("obj2"), count=True)
#
#         # ---------------- Property ----------------
#         m = PROPERTY_REGEX.match(question)
#         if m:
#             return self.answer_property(m.group("prop"), m.group("obj"))
#
#         # ---------------- Emotion Yes/No ----------------
#         m = EMOTION_YN_REGEX.match(question)
#         if m:
#             obj_name = (m.group("obj1") or m.group("obj2") or m.group("obj3") or m.group("obj4"))
#             emotion = (m.group("emo1") or m.group("emo2") or m.group("emo3") or m.group("emo4"))
#             return self.answer_emotion(obj_name, emotion)
#
#         return None



# from collections import Counter
# from Controllers.scene_questions import *
#
# PRONOUN_MAP = {
#     "he": "person",
#     "she": "person",
#     "him": "person",
#     "her": "person",
#     "they": "person",
#     "them": "person"
# }
#
# class SceneHandler:
#     INVERSE_RELATIONS = {
#         "left of": "right of",
#         "right of": "left of",
#         "above": "below",
#         "below": "above",
#         "in front of": "behind",
#         "behind": "in front of"
#     }
#     def __init__(self, objects, scene_graph, properties):
#         self.objects = objects
#         self.scene_graph = scene_graph
#         self.properties = {o: p for o, p in zip(objects, properties)}
#
#     def answer_relation(self, relation, obj, count=False):
#         obj = self.resolve_object(obj)
#         if not obj:
#             return f"Object not present."
#
#         matches = [
#             e["from"] for e in self.scene_graph
#             if e["relation"] == relation and e["to"] == obj
#         ]
#
#         inv = self.INVERSE_RELATIONS.get(relation)
#         if inv:
#             matches += [
#                 e["to"] for e in self.scene_graph
#                 if e["relation"] == inv and e["from"] == obj
#             ]
#
#         if count:
#             return f"There are {len(matches)} objects {relation} {obj}."
#
#         return (
#             f"Yes, {', '.join(set(matches))} are {relation} {obj}."
#             if matches else f"No objects are {relation} {obj}."
#         )
#
#     def debug(self):
#         import pprint
#         pp = pprint.PrettyPrinter(indent=4)
#
#         print("\n--- OBJECTS ---")
#         pp.pprint(self.objects)
#
#         print("\n--- SCENE GRAPH ---")
#         pp.pprint(self.scene_graph)
#
#         print("\n--- PROPERTIES ---")
#         pp.pprint(self.properties)
#     # ---------------- Counting Answers ----------------
#     def answer_count_specific(self, obj_name):
#         obj_name = obj_name.strip().lower()
#         matches = [
#             o for o in self.objects
#             if o.lower() == obj_name or o.lower().startswith(obj_name)
#         ]
#         return f"There are {len(matches)} {obj_name}."
#
#     def answer_count_container(self, obj_name, container, prep):
#         obj_name = obj_name.strip().lower()
#         container = container.strip().lower()
#         if prep == "there in":
#             prep = "in"
#         matches = [
#             edge["from"]
#             for edge in self.scene_graph
#             if edge["relation"].lower() == prep
#             and edge["to"].lower() == container
#             and edge["from"].lower().startswith(obj_name)
#         ]
#         return f"There are {len(matches)} {obj_name}(s) {prep} the {container}."
#
#     # ---------------- Utilities ----------------
#     def resolve_pronouns(self, text):
#         return " ".join(PRONOUN_MAP.get(w, w) for w in text.lower().split())
#
#     def resolve_object(self, name):
#         exact = [o for o in self.objects if o.lower() == name.lower()]
#         if exact:
#             return exact[0]
#         prefix = [o for o in self.objects if o.lower().startswith(name.lower())]
#         return prefix[0] if len(prefix) == 1 else None
#
#     # ---------------- Summary ----------------
#     def answer_summary(self, q):
#         if "how many" in q:
#             return f"There are {len(self.objects)} objects present."
#         # if "what objects" in q:
#         #     return f"The objects present are: {', '.join(self.objects)}."
#         counts = Counter(self.objects)
#         return "The objects in front are: " + ", ".join(
#             f"{v} {k}{'s' if v > 1 else ''}" for k, v in counts.items()
#         )
#
#     # ---------------- Movement ----------------
#     def answer_movement(self, obj_name, action):
#         obj = self.resolve_object(obj_name)
#         action = action.lower()
#         if action in {"come", "comes", "enter", "enters"}:
#             return f"Yes the {obj_name} has entered" if obj else f"No, {obj_name} is not entered right now"
#         if action in {"leave", "leaves", "left"}:
#             return f"No, the {obj_name} is still inside the room." if obj else f"Yes, the {obj_name} has left the room."
#
#     # ---------------- Relations ----------------
#     def answer_relation(self, relation, obj_name, count=False):
#         obj = self.resolve_object(obj_name)
#         if not obj:
#             return f"Object {obj_name} not present"
#
#         relation = relation.lower()
#         norm = self.normalize_relation
#
#         # DIRECT: something → relation → object
#         direct = [
#             e["from"] for e in self.scene_graph
#             if norm(e["relation"]) == relation
#                and e["to"].lower() == obj.lower()
#         ]
#
#         # INVERSE: object → inverse_relation → something
#         inverse_rel = self.INVERSE_RELATIONS.get(relation)
#         inverse = []
#
#         if inverse_rel:
#             inverse = [
#                 e["to"] for e in self.scene_graph
#                 if norm(e["relation"]) == inverse_rel
#                    and e["from"].lower() == obj.lower()
#             ]
#
#         matches = direct + inverse
#
#         if count:
#             return f"There are {len(matches)} objects {relation} {obj}."
#
#         return (
#             f"Yes, {', '.join(set(matches))} is/are {relation} {obj}."
#             if matches
#             else f"No objects are {relation} {obj}."
#         )
#
#     def normalize_relation(self, r):
#         return r.replace("_", " ").lower().strip()
#
#     # ---------------- Property ----------------
#     def answer_property(self, prop, obj_name):
#         obj = self.resolve_object(obj_name)
#         if not obj:
#             return f"❌ Object {obj_name} not present"
#         value = self.properties.get(obj, {}).get(prop)
#         if prop.lower() == "emotion":
#             if value in {None, "none", "not_applicable"}:
#                 return "Emotion is not applicable for this object."
#             return f"{obj} is {value}"
#         return value
#
#     # ---------------- Emotion Yes/No ----------------
#     def answer_emotion(self, obj_name, emotion):
#         obj = self.resolve_object(obj_name)
#         if not obj:
#             return f"Object {obj_name} not present"
#         obj_emotion = self.properties.get(obj, {}).get("emotion")
#         if obj_emotion in {None, "none", "not_applicable"}:
#             return "Emotion is not applicable for this object."
#         return f"Yes,Person is {emotion}" if obj_emotion.lower() == emotion.lower() else f"No, Person is not {emotion}"
#
#
#     # ---------------- Main Entry ----------------
#     def ask(self, question):
#         question = self.resolve_pronouns(question.strip().lower())
#
#         # ---------------- Summary ----------------
#         if question in SUMMARY_QUESTIONS:
#             return self.answer_summary(question)
#
#         # ---------------- Object existence ----------------
#         m = OBJECT_EXISTENCE_REGEX.match(question)
#         if m:
#             return f"Yes, {m.group('obj')} is present." if self.resolve_object(m.group("obj")) else f"No, {m.group('obj')} is not present."
#
#         m = OBJECT_EXISTENCE_ALT_REGEX.match(question)
#         if m:
#             return f"Yes, {m.group('obj')} is present." if self.resolve_object(m.group("obj")) else f"No, {m.group('obj')} is not present."
#
#
#         if m := RELATION_EXISTENCE_REGEX.match(question):
#             return self.answer_relation(
#                 m.group("relation"),
#                 m.group("object"),
#                 count=False
#             )
#
#         # ---------------- Relation count ----------------
#         if m := RELATION_COUNT_REGEX.match(question):
#             return self.answer_relation(
#                 m.group("relation"),
#                 m.group("object"),
#                 count=True
#             )
#         # ---------------- Counting ----------------
#         m = COUNT_SPECIFIC_REGEX.match(question)
#         if m:
#             return self.answer_count_specific(m.group("obj"))
#
#         m = COUNT_CONTAINER_REGEX.match(question)
#         if m:
#             return self.answer_count_container(m.group("obj"), m.group("container"), m.group("prep"))
#
#         # ---------------- Movement ----------------
#         m = MOVEMENT_REGEX.match(question)
#         if m:
#             return self.answer_movement(m.group("obj"), m.group("action"))
#
#         # ---------------- Relations ----------------
#         # m = RELATION_REGEX.match(question)
#         # if m:
#         #     if m.group("rel1"):
#         #         return self.answer_relation(m.group("rel1"), m.group("obj1"))
#         #     return self.answer_relation(m.group("rel2"), m.group("obj2"), count=True)
#
#         if m := MOVEMENT_REGEX.match(question):
#             return self.answer_movement(m.group("obj"), m.group("action"))
#
#
#         # ---------------- Property ----------------
#         m = PROPERTY_REGEX.match(question)
#         if m:
#             return self.answer_property(m.group("prop"), m.group("obj"))
#
#         # ---------------- Emotion Yes/No ----------------
#         m = EMOTION_YN_REGEX.match(question)
#         if m:
#             obj_name = (m.group("obj1") or m.group("obj2") or m.group("obj3") or m.group("obj4"))
#             emotion = (m.group("emo1") or m.group("emo2") or m.group("emo3") or m.group("emo4"))
#             return self.answer_emotion(obj_name, emotion)
#
#         return None



from collections import Counter
from Controllers.scene_questions import *

PRONOUN_MAP = {
    "he": "person",
    "she": "person",
    "him": "person",
    "her": "person",
    "they": "person",
    "them": "person"
}

class SceneHandler:
    INVERSE_RELATIONS = {
        "left of": "right of",
        "right of": "left of",
        "above": "below",
        "below": "above",
        "in front of": "behind",
        "behind": "in front of"
    }
    def __init__(self, objects, scene_graph, properties):
        self.objects = objects
        self.scene_graph = scene_graph
        self.properties = {o: p for o, p in zip(objects, properties)}
        self.MONITOR_REGEX = re.compile(
            r"^(let\s+me\s+know\s+when|Monitor\s)(?P<obj1>[\w\s]+?)(?:s)?\s+(?P<action>emotion\s+changes|smiles|happy|smile)\??$",
            re.IGNORECASE
        )
        self.TEMP_REGEX = re.compile(
            r"^let\s+me\s+know\s+(when|if)\s(?P<obj>[\w\s]+?)(?:s)?\s+(?P<action>leaves|leave|left|comes|come|enter|enters)\??$",
            re.IGNORECASE
        )

    def answer_relation(self, relation, obj, count=False):
        obj = self.resolve_object(obj)
        if not obj:
            return f"Object not present."

        matches = [
            e["from"] for e in self.scene_graph
            if e["relation"] == relation and e["to"] == obj
        ]

        inv = self.INVERSE_RELATIONS.get(relation)
        if inv:
            matches += [
                e["to"] for e in self.scene_graph
                if e["relation"] == inv and e["from"] == obj
            ]

        if count:
            return f"There are {len(matches)} objects {relation} {obj}."

        return (
            f"Yes, {', '.join(set(matches))} are {relation} {obj}."
            if matches else f"No objects are {relation} {obj}."
        )

    def task_answer(self, obj_name, question,action):
        from nltk import word_tokenize
        print("In task Answer")
        print(action)
        obj = self.resolve_object(obj_name)
        print(obj)
        tokens=word_tokenize(str(question))
        print(tokens)

        if action in {"come", "comes", "enter", "enters"}:
            return f"Enter" if obj else f"Not Entered"
        if action in {"leave", "leaves", "left"}:
            return f"left" if obj==None else f"room"

    def task_answer_emotion(self, obj_name):
        print("In task Emotion Answer")
        obj = self.resolve_object(obj_name)
        print(obj)
        obj_emotion = self.properties.get(obj, {}).get("emotion")
        if obj_emotion in {None, "none", "not_applicable"}:
            return "Emotion is not applicable for this object."
        return f"{obj_emotion}" if obj_emotion.lower() == obj_emotion.lower() else f"{obj_emotion}"


    def debug(self):
        import pprint
        pp = pprint.PrettyPrinter(indent=4)

        print("\n--- OBJECTS ---")
        pp.pprint(self.objects)

        print("\n--- SCENE GRAPH ---")
        pp.pprint(self.scene_graph)

        print("\n--- PROPERTIES ---")
        pp.pprint(self.properties)
    # ---------------- Counting Answers ----------------
    def answer_count_specific(self, obj_name):
        obj_name = obj_name.strip().lower()
        matches = [
            o for o in self.objects
            if o.lower() == obj_name or o.lower().startswith(obj_name)
        ]
        return f"There are {len(matches)} {obj_name}."

    def answer_count_container(self, obj_name, container, prep):
        obj_name = obj_name.strip().lower()
        container = container.strip().lower()
        if prep == "there in":
            prep = "in"
        matches = [
            edge["from"]
            for edge in self.scene_graph
            if edge["relation"].lower() == prep
            and edge["to"].lower() == container
            and edge["from"].lower().startswith(obj_name)
        ]
        return f"There are {len(matches)} {obj_name}(s) {prep} the {container}."

    # ---------------- Utilities ----------------
    def resolve_pronouns(self, text):
        return " ".join(PRONOUN_MAP.get(w, w) for w in text.lower().split())

    def resolve_object(self, name):
        exact = [o for o in self.objects if o.lower() == name.lower()]
        if exact:
            return exact[0]
        prefix = [o for o in self.objects if o.lower().startswith(name.lower())]
        return prefix[0] if len(prefix) == 1 else None

    # ---------------- Summary ----------------
    def answer_summary(self, q):
        if "how many" in q:
            return f"There are {len(self.objects)} objects present."
        # if "what objects" in q:
        #     return f"The objects present are: {', '.join(self.objects)}."
        counts = Counter(self.objects)
        return "The objects in front are: " + ", ".join(
            f"{v} {k}{'s' if v > 1 else ''}" for k, v in counts.items()
        )

    # ---------------- Movement ----------------
    # def answer_movement(self, obj_name, action):
    #     obj = self.resolve_object(obj_name)
    #     action = action.lower()
    #     if action in {"come", "comes", "enter", "enters"}:
    #         return f"Yes the {obj_name} has entered" if obj else f"No, {obj_name} is not entered right now"
    #     if action in {"leave", "leaves", "left"}:
    #         return f"No, the {obj_name} is still inside the room." if obj else f"Yes, the {obj_name} has left the room."




    # ---------------- Relations ----------------
    def answer_relation(self, relation, obj_name, count=False):
        obj = self.resolve_object(obj_name)
        if not obj:
            return f"Object {obj_name} not present"

        relation = relation.lower()
        norm = self.normalize_relation

        # DIRECT: something → relation → object
        direct = [
            e["from"] for e in self.scene_graph
            if norm(e["relation"]) == relation
               and e["to"].lower() == obj.lower()
        ]

        # INVERSE: object → inverse_relation → something
        inverse_rel = self.INVERSE_RELATIONS.get(relation)
        inverse = []

        if inverse_rel:
            inverse = [
                e["to"] for e in self.scene_graph
                if norm(e["relation"]) == inverse_rel
                   and e["from"].lower() == obj.lower()
            ]

        matches = direct + inverse

        if count:
            return f"There are {len(matches)} objects {relation} {obj}."

        return (
            f"Yes, {', '.join(set(matches))} is/are {relation} {obj}."
            if matches
            else f"No objects are {relation} {obj}."
        )

    def normalize_relation(self, r):
        return r.replace("_", " ").lower().strip()

    # ---------------- Property ----------------
    def answer_property(self, prop, obj_name):
        obj = self.resolve_object(obj_name)
        if not obj:
            return f"❌ Object {obj_name} not present"
        value = self.properties.get(obj, {}).get(prop)
        if prop.lower() == "emotion":
            if value in {None, "none", "not_applicable"}:
                return "Emotion is not applicable for this object."
            return f"{obj} is {value}"
        return value

    # ---------------- Emotion Yes/No ----------------
    def answer_emotion(self, obj_name, emotion):
        obj = self.resolve_object(obj_name)
        if not obj:
            return f"Object {obj_name} not present"
        obj_emotion = self.properties.get(obj, {}).get("emotion")
        if obj_emotion in {None, "none", "not_applicable"}:
            return "Emotion is not applicable for this object."
        return f"Yes,Person is {emotion}" if obj_emotion.lower() == emotion.lower() else f"No, Person is not {emotion}"


    # ---------------- Main Entry ----------------
    def ask(self, question):
        print("recieved : ",question)
        question = self.resolve_pronouns(question.strip().lower())


        # ---------------- Summary ----------------
        if question in SUMMARY_QUESTIONS:
            return self.answer_summary(question)
        print("Not a summary question")
        # ---------------- Object existence ----------------
        m = OBJECT_EXISTENCE_REGEX.match(question)
        if m:
            return f"Yes, {m.group('obj')} is present." if self.resolve_object(m.group("obj")) else f"No, {m.group('obj')} is not present."
        print("Not a Existence question")
        m = OBJECT_EXISTENCE_ALT_REGEX.match(question)
        if m:
            return f"Yes, {m.group('obj')} is present." if self.resolve_object(m.group("obj")) else f"No, {m.group('obj')} is not present."

        print("Not a Existence ALT question")
        if m := RELATION_EXISTENCE_REGEX.match(question):
            return self.answer_relation(
                m.group("relation"),
                m.group("object"),
                count=False
            )

        print(type(question))
        m = self.TEMP_REGEX.match(question)
        print(m)
        n = self.MONITOR_REGEX.match(question)
        print(n)

        if m!=None:
            return self.task_answer(m.group("obj"),question,m.group("action"))
        if n!=None:
            return self.task_answer_emotion(n.group("obj1"))


        print("Not a Relation question")
        # ---------------- Relation count ----------------
        if m := RELATION_COUNT_REGEX.match(question):
            return self.answer_relation(
                m.group("relation"),
                m.group("object"),
                count=True
            )
        print("Not a Relation Count question")
        # ---------------- Counting ----------------
        m = COUNT_SPECIFIC_REGEX.match(question)
        if m:
            return self.answer_count_specific(m.group("obj"))

        print("Not a Count question")
        m = COUNT_CONTAINER_REGEX.match(question)
        if m:
            return self.answer_count_container(m.group("obj"), m.group("container"), m.group("prep"))
        print("Not a CC question")
        # ---------------- Movement ----------------
        # m = MOVEMENT_REGEX.match(question)
        # if m:
        #     return self.answer_movement(m.group("obj"), m.group("action"))

        # ---------------- Relations ----------------
        # m = RELATION_REGEX.match(question)
        # if m:
        #     if m.group("rel1"):
        #         return self.answer_relation(m.group("rel1"), m.group("obj1"))
        #     return self.answer_relation(m.group("rel2"), m.group("obj2"), count=True)


        # if m := MOVEMENT_REGEX.match(question):
        #     return self.answer_movement(m.group("obj"), m.group("action"))


        # ---------------- Property ----------------
        m = PROPERTY_REGEX.match(question)
        if m:
            return self.answer_property(m.group("prop"), m.group("obj"))
        print("Not a property question")
        # ---------------- Emotion Yes/No ----------------
        m = EMOTION_YN_REGEX.match(question)
        if m:
            obj_name = (m.group("obj1") or m.group("obj2") or m.group("obj3") or m.group("obj4"))
            emotion = (m.group("emo1") or m.group("emo2") or m.group("emo3") or m.group("emo4"))
            return self.answer_emotion(obj_name, emotion)
        print("Not a emotion question")
        return None

