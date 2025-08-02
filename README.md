Flutter Riverpod Quiz App

A beautiful, modern quiz application built using Flutter and Riverpod. Features async question fetching from the Open Trivia Database, robust error handling, elegant UI, and modular architecture for easy learning and extension.

Features
⚡ Riverpod State Management – Clean separation of business logic, data, and UI

🎲 Randomized Questions – Fetches categories and difficulties using Open Trivia Database API

🍃 Splash-to-Quiz Flow – Data is loaded during the splash screen so the quiz is always ready, not loading

💡 Modern UI – Beautiful gradients, feedback animations, Material style, and responsive layout

💾 Null Safety & Immutability – All code and models use Dart null safety and Equatable

🚦 Error & Retry Handling – User-friendly error messages and "Retry" on load failures

🔁 New Quiz – Easily restart and get new random questions

🧩 Extensible & Testable – Add more screens or change the quiz source with ease

Getting Started
1. Clone this repository:

bash
git clone https://github.com/YOUR-USERNAME/riverpod_quiz_app.git
cd riverpod_quiz_app
2. Install dependencies:

bash
flutter pub get
3. Run the app:

bash
flutter run
Project Structure
text
lib/
  controllers/          // State management (QuizController & QuizState)
  enums/                // Difficulty enums, others
  models/               // Data models: Question, Failure, etc.
  repositories/         // Quiz repository (API communication)
  screen/               // Splash screen, other UI screens
  main.dart             // App root, providers, and entry point
assets/
  app_screenshot.png    // (Add your app screenshots here)


Technologies Used
  Flutter

  Riverpod

  hooks_riverpod

  Dio

  Equatable

  html_character_entities

  Open Trivia Database API


How It Works

SplashScreen loads first, pre-fetching quiz data in the background. When ready, the user transitions seamlessly to the quiz.

QuizScreen displays each question, allows answer selection, provides immediate feedback, and tracks results.

Error Handling is built into network calls (Dio). Users can retry or start a new quiz on demand.

State Management leverages StateNotifier and Riverpod’s providers to ensure robust, scalable code.


Customization

Change number of questions/difficulty: Adjust the parameters in quizQuestionsProvider in main.dart.

Add categories: Change the API parameters in the QuizRepository.

Styling: Update the gradients, colors, and widget layouts as needed.

More features: Add scoreboard, time tracking, or persistent history!


Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you’d like to change.


License
MIT License. See LICENSE for details.


Credits
Open Trivia Database for the public quiz API.


Flutter, Riverpod, and open source package authors.

Enjoy the quiz! Made with ❤️ and Riverpod.
