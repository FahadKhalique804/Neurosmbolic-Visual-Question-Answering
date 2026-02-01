# Neuro-Symbolic Visual Question Answering System

An intelligent assistive application that enables visually impaired users to understand their surroundings by asking natural language questions about images. The system combines deep learning–based visual perception with symbolic reasoning and chain-of-thought logic to deliver accurate, explainable answers.

![Project Banner](https://raw.githubusercontent.com/FahadKhalique804/Neurosmbolic-Visual-Question-Answering/main/NSVQA.png)

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688?style=flat&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev/)
[![OpenCV](https://img.shields.io/badge/OpenCV-4.x-5C3EE8?style=flat&logo=opencv&logoColor=white)](https://opencv.org/)
[![YOLO](https://img.shields.io/badge/YOLOv8-8.x-00FFFF?style=flat&logo=yolo&logoColor=black)](https://yolov8.com/)
[![Whisper](https://img.shields.io/badge/Whisper-OpenAI-FF69B4?style=flat&logo=openai&logoColor=white)](https://openai.com/research/whisper)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Accessibility](https://img.shields.io/badge/Accessibility-Visually%20Impaired-blueviolet?style=flat)](https://github.com/topics/accessibility)

## 🚀 Features

- **Voice-Based Interaction**: Ask questions using speech and receive spoken responses.
- **Scene Understanding**: Detects objects, their attributes (color, shape), and spatial relationships (left/right, on, near).
- **Neuro-Symbolic Reasoning**: Uses a hybrid approach (CFG -> Regex -> ML) for robust question answering.
- **Explainable AI**: Provides transparency into how the answer was derived.

### 🧠 AI Capabilities

- **Neuro-Symbolic VQA:** Combines neural perception (vision + NLP) with symbolic reasoning.
- **Chain-of-Thought Reasoning:** Logical steps are applied internally to improve multi-hop reasoning.
- **Scene Graph Generation:** Converts detected objects into structured symbolic representations.
- **Robotic Command Grounding (Extensible):** Architecture supports grounding answers into executable commands for assistive robots.

---

## 🛠️ Tech Stack

- **Backend:** Python (Flask / FastAPI)
- **Computer Vision:** OpenCV, Object Detection Models (YOLO / Faster R-CNN)
- **NLP:** Transformer-based Question Parsing
- **Reasoning Engine:** Symbolic Logic Rules, CFG-based Parsing
- **AI Architecture:** Neuro-Symbolic Framework with Chain-of-Thought
- **Frontend:** Flutter (Mobile/Desktop)
- **Speech:** Speech-to-Text (Whisper), Text-to-Speech
- **Database:** SQLite / MySQL (for logs & history)

---

## ⚙️ Prerequisites

- **Python 3.9+**
- **Flutter SDK** (for frontend)
- **Git**

## 📥 Installation

### 1. Backend Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/YourUsername/neurosymbolic-visual-question-answering.git
    cd neurosymbolic-visual-question-answering/Backend
    ```

2.  **Create a virtual environment (Recommended):**
    ```bash
    python -m venv venv
    # Windows
    venv\Scripts\activate
    # Mac/Linux
    source venv/bin/activate
    ```

3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Download NLTK Data:**
    Run the downloader script to fetch necessary NLTK models:
    ```bash
    python download.py
    ```

### 2. Frontend Setup

1.  **Navigate to the Frontend directory:**
    ```bash
    cd ../Frontend
    ```

2.  **Install Flutter dependencies:**
    ```bash
    flutter pub get
    ```

## 🏃 Usage

### Start the Backend
```bash
# In the Backend directory (with venv activated)
python app.py
```
The server will start at `http://0.0.0.0:5000`.

### Start the Frontend
```bash
# In the Frontend directory
flutter run
```
Choose your target device (Chrome, Windows, or a connected Mobile device).

## 📂 Project Structure

```
neurosymbolic-visual-question-answering/
├── Backend/
│   ├── Controllers/       # Logic for Vision, NLP, and Reasoning
│   ├── Models/            # Data models and KG logic
│   ├── Routes/            # API Endpoints (Flask Blueprints)
│   ├── Services/          # Helper services
│   ├── modelsNSVQA/       # ML Models (YOLO, classifiers)
│   ├── app.py             # Main Entry Point
│   └── requirements.txt   # Python Dependencies
├── Frontend/
│   ├── lib/               # Flutter Source Code
│   └── pubspec.yaml       # Flutter Dependencies
└── README.md
```

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## 📄 License

Distributed under the MIT License.
