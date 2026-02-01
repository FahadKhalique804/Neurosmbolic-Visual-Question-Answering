# Neuro-Symbolic Visual Question Answering System for Visually Impaired

An intelligent assistive application that enables visually impaired users to understand their surroundings by asking natural language questions about images. The system combines deep learning–based visual perception with symbolic reasoning and chain-of-thought logic to deliver accurate, explainable answers and grounded actions.

Designed as a neuro-symbolic AI framework, this project improves interpretability, robustness, and reasoning compared to purely neural VQA systems.

![Project Banner](https://raw.githubusercontent.com/FahadKhalique804/neurosymbolic-visual-question-answering/main/NSVQA.png)

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688?style=flat&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev/)
[![OpenCV](https://img.shields.io/badge/OpenCV-4.x-5C3EE8?style=flat&logo=opencv&logoColor=white)](https://opencv.org/)
[![YOLO](https://img.shields.io/badge/YOLOv8-8.x-00FFFF?style=flat&logo=yolo&logoColor=black)](https://yolov8.com/)
[![Whisper](https://img.shields.io/badge/Whisper-OpenAI-FF69B4?style=flat&logo=openai&logoColor=white)](https://openai.com/research/whisper)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Accessibility](https://img.shields.io/badge/Accessibility-Visually%20Impaired-blueviolet?style=flat)](https://github.com/topics/accessibility)

**Neuro-Symbolic • Explainable AI • Assistive Technology • VQA**

---

## 🚀 Key Features #VQA #AssistiveAI #NeuroSymbolic

### 👁️ For Visually Impaired Users
- **Voice-Based Interaction:** Ask questions using speech input and receive spoken responses.
- **Scene Understanding:** Understand objects, their properties, and relationships in an image.
- **Natural Language Queries:** Ask complex questions like “Is there a person near the chair?” or “What is on the table?”
- **Explainable Answers:** Reasoning is grounded in symbolic logic, not just black-box predictions.

### 🧠 AI Capabilities #ExplainableAI #ChainOfThought
- **Neuro-Symbolic VQA:** Combines neural perception (vision + NLP) with symbolic reasoning.
- **Chain-of-Thought Reasoning:** Logical steps are applied internally to improve multi-hop reasoning.
- **Scene Graph Generation:** Converts detected objects into structured symbolic representations.
- **Robotic Command Grounding (Extensible):** Architecture supports grounding answers into executable commands for assistive robots.

---

## 🛠️ Tech Stack #Python #ComputerVision #NLP

- **Backend:** Python (Flask / FastAPI)
- **Computer Vision:** OpenCV, Object Detection Models (YOLO / Faster R-CNN)
- **NLP:** Transformer-based Question Parsing
- **Reasoning Engine:** Symbolic Logic Rules, CFG-based Parsing
- **AI Architecture:** Neuro-Symbolic Framework with Chain-of-Thought
- **Frontend:** Flutter (Mobile/Desktop)
- **Speech:** Speech-to-Text (Whisper), Text-to-Speech
- **Database:** SQLite / MySQL (for logs & history)

---

## ⚙️ System Workflow #AIWorkflow

1. User captures or uploads an image.
2. User asks a question via voice or text.
3. Object detection and scene understanding are applied.
4. A scene graph is constructed.
5. The question is parsed into symbolic logic.
6. Chain-of-thought reasoning is applied over the scene graph.
7. The final grounded answer is generated and spoken back to the user.

---

## ⚙️ Setup Instructions

### 1. Backend Setup
```bash
# Clone the repository
git clone https://github.com/FahadKhalique804/neurosymbolic-visual-question-answering.git
cd neurosymbolic-visual-question-answering

# Navigate to backend
cd backend

# Create & activate virtual environment
python -m venv venv
source venv/bin/activate          # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start the server
python app.py

### 2. Frontend Setup
```bash
# From project root
cd frontend

# Install dependencies
flutter pub get

# Run the app (choose target: chrome, windows, android, etc.)
flutter run -d chrome
# or: flutter run -d windows
# or: flutter run    # for connected device

##📂 Project Structure
neurosymbolic-visual-question-answering/
├── backend/
│   ├── Controllers/          # Question, Image & Reasoning Handlers
│   ├── Models/               # CFG, Scene Graph, Logic Models
│   ├── Services/             # NLP, Vision, Speech Processing
│   ├── app.py                # Main API Server (Flask/FastAPI)
│   ├── requirements.txt
│   └── ...
├── frontend/
│   ├── lib/
│   │   ├── screens/          # UI Screens (capture, question, result, settings…)
│   │   ├── services/         # API client, speech recognition/synthesis
│   │   ├── widgets/          # Reusable components
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── ...
├── README.md
└── LICENSE

##🎯 Use Cases #Accessibility #AssistiveTech

Assist visually impaired users in understanding indoor and outdoor scenes.
Educational demonstration of Neuro-Symbolic AI.
Foundation for assistive robotics and embodied AI systems.
Research-oriented VQA with explainability.

##🤝 Contributing

Fork the repository.
Create your feature branchBashgit checkout -b feature/amazing-feature
Commit your changesBashgit commit -m 'Add some amazing feature'
Push to the branchBashgit push origin feature/amazing-feature
Open a Pull Request.

We welcome contributions — bug fixes, new features, documentation, or model improvements!

##📄 License
Distributed under the MIT License.