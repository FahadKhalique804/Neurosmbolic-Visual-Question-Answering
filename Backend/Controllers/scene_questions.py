import re
from enum import Enum

# =========================
# Question Categories
# =========================
class QuestionType(Enum):
    SUMMARY = "summary"
    OBJECT_EXISTENCE = "object_existence"
    MOVEMENT = "movement"
    RELATION_EXISTENCE = "relation_existence"
    RELATION_COUNT = "relation_count"
    PROPERTY = "property"
    UNKNOWN = "unknown"


# =========================
# Supported Relations
# =========================
RELATIONS = ["left of", "right of", "below", "near", "on","in front of","behind"]
REL_PATTERN = "|".join(map(re.escape, RELATIONS))


# =========================
# Regex Expressions
# =========================

SUMMARY_QUESTIONS = {
    "what is in front of me?": QuestionType.SUMMARY,
    "tell me how many objects are present?": QuestionType.SUMMARY,
    "can you tell me what objects are here?": QuestionType.SUMMARY
}
# =========================
# Counting Regexes
# =========================

# "How many <obj> are there?" / "How many <obj> present?"
COUNT_SPECIFIC_REGEX = re.compile(
    r"""^how\s+many\s+(?P<obj>[\w\s]+?)(?:s)?
        \s+are\s+(there|present)
        (?:\s+in\s+the\s+scene)?
        \??$""",
    re.IGNORECASE | re.VERBOSE
)

# "How many <obj> are in/on the <container>?"
COUNT_CONTAINER_REGEX = re.compile(
    r"""^how\s+many\s+(?P<obj>[\w\s]+?)(?:s)?
        \s+are\s+(?P<prep>in|on|there\s+in)
        \s+(the\s+)?(?P<container>[\w\s]+)
        \??$""",
    re.IGNORECASE | re.VERBOSE
)

OBJECT_EXISTENCE_REGEX = re.compile(
    r"^is there a (?P<obj>\w+)\?$",
    re.IGNORECASE
)

MOVEMENT_REGEX = re.compile(
    rf"""^tell\s+me\s+if\s+(?P<obj>\w+)
        (?:\s+in\s+center)?
        \s+(?P<action>leave|leaves|left|come|comes|enter|enters)
        (?:\s+the\s+room)?
        \s*[\?\.\!]?$""",
    re.IGNORECASE | re.VERBOSE
)

RELATION_EXISTENCE_REGEX = re.compile(
    rf"""^is\s+(there\s+)?anything\s+
        (?P<relation>{REL_PATTERN})\s+
        (?P<object>[\w\s]+)\?$""",
    re.IGNORECASE | re.VERBOSE
)

RELATION_COUNT_REGEX = re.compile(
    rf"""^how\s+many\s+objects\s+
        (?P<relation>{REL_PATTERN})\s+
        (?P<object>[\w\s]+)\?$""",
    re.IGNORECASE | re.VERBOSE
)

PROPERTY_REGEX = re.compile(
    r"^(tell me|what is the)\s+(?P<prop>\w+)\s+of\s+(?P<obj>\w+)\?$",
    re.IGNORECASE
)

OBJECT_EXISTENCE_ALT_REGEX = re.compile(
    r"""^(do\s+you\s+see|is\s+any|can\s+you\s+find)
        \s+(a|any)?\s*(?P<obj>\w+)
        (\s+present)?\??$""",
    re.IGNORECASE | re.VERBOSE
)

EMOTIONS = ["angry", "disgust", "fear", "happy", "sad", "surprise", "neutral"]

EMOTION_PATTERN = "|".join(EMOTIONS)

EMOTION_YN_REGEX = re.compile(
    rf"""^(
        is\s+(the\s+)?(?P<obj1>\w+)\s+(?P<emo1>{EMOTION_PATTERN}) |

        does\s+(the\s+)?(?P<obj2>\w+)\s+(look|seem)\s+(?P<emo2>{EMOTION_PATTERN}) |

        is\s+(the\s+)?(?P<obj3>\w+)\s+looking\s+(?P<emo3>{EMOTION_PATTERN}) |

        is\s+(the\s+)?(?P<obj4>\w+)\s+in\s+(a\s+)?(?P<emo4>{EMOTION_PATTERN})\s+mood
    )\??$""",
    re.IGNORECASE | re.VERBOSE
)
