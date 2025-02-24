
---

# Lumos: Sense-Connect  

Lumos: Sense-Connect is an AI-powered assistive mobile application designed to help individuals with visual, auditory, and speech impairments. The app provides real-time object recognition, text-to-speech conversion, speech-to-text transcription, currency identification, hand gesture recognition, and color detection, making daily interactions more accessible.  

## Features  

### 🔍 Object Recognition  
- Identifies objects in real time and provides audio descriptions using deep learning models like YOLO, MobileNet, or EfficientNet.  

### 🗣 Speech-to-Text Conversion  
- Converts spoken words into text for easy communication with hearing-impaired individuals.  
- Uses Google Speech-to-Text API or Deep Speech models for high accuracy.  

### 🏷 Text-to-Speech Synthesis  
- Reads out printed or digital text using AI-based speech synthesis (Tacotron + WaveNet).  
- Supports multiple languages with adjustable voice pitch and speed.  

### 🎨 Color Blindness Assistance  
- Identifies and announces colors in real-time using image processing techniques.  

### 💵 Currency Identifier  
- Recognizes and announces currency denominations for visually impaired users using OCR (Tesseract or EasyOCR).  

### ✋ Hand Gesture Recognition (ASL Support)  
- Converts American Sign Language (ASL) hand gestures into readable text.  

### 🆘 Emergency Support  
- Sends SOS messages with live GPS location for safety.  

## 📌 Technologies Used  
- **Frontend:** Flutter (Dart)  
- **Backend:** Flask (Python)  
- **AI Models:** TensorFlow Lite (TFLite), Google ML Kit  
- **APIs & Libraries:** Speech-to-Text API, OCR (Tesseract, EasyOCR), OpenCV for image processing  
- **Deployment:** Google Cloud Run / AWS Lambda  

## 🔧 Installation & Setup  

### Prerequisites  
Ensure you have:  
- Flutter installed (`flutter --version`)  
- Python 3.8+ installed  
- Required dependencies (`pip install -r requirements.txt`)  

### Clone the Repository  
```sh  
git clone https://github.com/PrashanthVurugonda/lumos-sense-connect.git  
cd lumos-sense-connect  
```

### Backend Setup  
```sh  
cd backend  
pip install -r requirements.txt  
python app.py  
```

### Frontend Setup  
```sh  
cd frontend  
flutter pub get  
flutter run  
```

## 📌 Usage  
- **"Take Picture"** → Captures an image and recognizes objects.  
- **"Read Mail"** → Fetches and reads unread emails from a predefined email address.  
- **"Send SOS"** → Sends an emergency email with GPS location to a trusted contact.  
- Voice feedback confirms all actions.  

## 🤝 Contributing  
1. Fork the repository  
2. Create a feature branch (`git checkout -b feature-name`)  
3. Commit changes (`git commit -m "Added new feature"`)  
4. Push to the branch (`git push origin feature-name`)  
5. Submit a pull request  

## 📜 License  
This project is licensed under the **MIT License**.  
