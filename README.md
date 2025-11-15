# 🍏 Nutri Health Tracker

Nutri Health Tracker is a Flutter mobile application designed to help users monitor nutrition, track health metrics, and interact with an AI assistant for personalized guidance. The app provides an easy-to-use interface, structured health tracking tools, and an intelligent chat assistant powered by Google’s Gemini API.

---

## ✨ Features

### 🔹 Profile Screen

- Manage personal details
- Update user information

---

### 🔹 AI Assistant (Gemini API)

- Ask nutrition, health, and fitness questions
- Receive instant, AI-powered guidance
- Chat-style interface

---

### 🔹 Meal Logger

- Log meals daily
- Track calories and nutrients

---

### 🔹 Health Tracker

- Track weight, BMI, sleep and water intake.
- AI insights

---

### 🔹 Firebase Integration

- Firebase App Distribution for testers
- Optional authentication (future expansion)

---

### 🔹 Clean UI

- Modern color themes
- Smooth navigation and responsive layout

---

## 🛠 Tech Stack

| Technology     | Purpose                         |
| -------------- | ------------------------------- |
| **Flutter**    | Mobile app development          |
| **Dart**       | Main programming language       |
| **Firebase**   | Distribution & backend services |
| **Gemini API** | AI-powered assistant            |
| **GitHub**     | Version control                 |

---

## 📦 Installation & Setup

### 1️⃣ Clone the repository

```bash
git clone https://github.com/JawamaKE/Nutri_Health_Tracker.git
cd Nutri_Health_Tracker

```

---

### 2️⃣ Install dependencies

```bash
flutter pub get
```

---

### 3️⃣ Run the app

```bash
flutter run
```

---

## 🔑 Environment Setup (Gemini API Key)

- Create a .env file in the project root:

- GEMINI_API_KEY=your_api_key_here

- Make sure you do not push your API key to GitHub.

---

## 📁 Project Structure

```bash
lib/
├── main.dart
├── home_screen.dart
├── ai_assistant_screen.dart
├── meal_logger_screen.dart
├── health_tracker_screen.dart
└── profile_screen.dart
```

---

## 🚀 Build Release APK

```bash
flutter build apk --release
```

- APK will be located at:

```bash
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🤝 Contributing

- Contributions, issues, and feature requests are welcome!
- Feel free to open a pull request.

---

## 📜 License

- This project is licensed under the MIT License.

---

## 👨‍💻 Author

- Jane Wangu Maina
- GitHub repository link: https://github.com/JawamaKE/Nutri_Health_Tracker
