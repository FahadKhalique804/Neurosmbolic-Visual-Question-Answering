import sounddevice as sd
from scipy.io.wavfile import write
import requests
import time
import os

# ===============================
# CONFIG
# ===============================
DURATION = 5              # seconds per recording
SAMPLE_RATE = 16000       # Whisper-friendly
OUTPUT_FILE = "recorded_test.wav"
API_URL = "http://127.0.0.1:5000/audio/voice/command"

print("\n🎤 Continuous Voice Command Tester")
print("🔁 Recording every 5 seconds")
print("❌ Press CTRL + C to stop\n")

try:
    while True:
        # ===============================
        # 1️⃣ Record Audio
        # ===============================
        print("🎙 Speak now...")
        audio = sd.rec(
            int(DURATION * SAMPLE_RATE),
            samplerate=SAMPLE_RATE,
            channels=1,
            dtype="int16"
        )
        sd.wait()

        # ===============================
        # 2️⃣ Save Audio
        # ===============================
        write(OUTPUT_FILE, SAMPLE_RATE, audio)

        # ===============================
        # 3️⃣ Send to API
        # ===============================
        with open(OUTPUT_FILE, "rb") as f:
            files = {
                "audio": ("recorded_test.wav", f, "audio/wav")
            }
            response = requests.post(API_URL, files=files)

        # ===============================
        # 4️⃣ Print Result
        # ===============================
        if response.status_code == 200:
            data = response.json()
            print("📝 Text     :", data.get("text"))
            print("🎯 Command  :", data.get("command"))
            print("💬 Message  :", data.get("message"))
        else:
            print("❌ Error:", response.text)

        print("-" * 50)
        time.sleep(1)  # small pause before next recording

except KeyboardInterrupt:
    print("\n🛑 Stopped by user")