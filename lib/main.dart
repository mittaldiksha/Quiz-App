import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:riverpod_quiz_app/repositories/quiz/quiz_repository.dart';
import 'package:riverpod_quiz_app/screen/splash_screen.dart';
import 'controllers/quiz/quiz_controller.dart';
import 'controllers/quiz/quiz_state.dart';
import 'enums/difficulty.dart';
import 'models/failure_model.dart';
import 'models/question_model.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Riverpod Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        bottomSheetTheme:
        const BottomSheetThemeData(backgroundColor: Colors.transparent),
      ),
      home: const SplashScreen(),
    );
  }
}

/// Use HookConsumerWidget for hooks + Riverpod access
class QuizScreen extends HookConsumerWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizQuestionsAsync = ref.watch(quizQuestionsProvider);
    final pageController = usePageController();

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD4418E), Color(0xFF0652C5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: quizQuestionsAsync.when(
          data: (questions) =>
              _buildBody(context, ref, pageController, questions),
          loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 3)),
          error: (error, _) => QuizError(
            message:
            error is Failure ? error.message : 'Something went wrong!',
          ),
        ),
        bottomSheet: quizQuestionsAsync.when(
          data: (questions) {
            final quizState = ref.watch(quizControllerProvider);
            if (!quizState.answered) return const SizedBox.shrink();
            final currentPage =
            pageController.hasClients ? pageController.page?.toInt() ?? 0 : 0;
            return CustomButton(
              title: currentPage + 1 < questions.length
                  ? 'Next Question'
                  : 'See Results',
              onTap: () {
                ref
                    .read(quizControllerProvider.notifier)
                    .nextQuestion(questions, currentPage);
                if (currentPage + 1 < questions.length) {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.linear,
                  );
                }
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref,
      PageController pageController, List<Question> questions) {
    if (questions.isEmpty) return const QuizError(message: 'No questions found.');

    final quizState = ref.watch(quizControllerProvider);
    return quizState.status == QuizStatus.complete
        ? QuizResults(state: quizState, questions: questions)
        : QuizQuestions(
      pageController: pageController,
      state: quizState,
      questions: questions,
    );
  }
}

class QuizError extends StatelessWidget {
  final String message;

  const QuizError({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        const SizedBox(height: 20.0),
        CustomButton(
          title: 'Retry',
          onTap: () {
            final container = ProviderScope.containerOf(context);
            container.refresh(quizQuestionsProvider);
          },
        ),
      ],
    ),
  );
}

final List<BoxShadow> boxShadow = const [
  BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 2),
    blurRadius: 4.0,
  ),
];

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CustomButton({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.all(20.0),
      height: 50.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.yellow[700],
        boxShadow: boxShadow,
        borderRadius: BorderRadius.circular(25.0),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class QuizResults extends StatelessWidget {
  final QuizState state;
  final List<Question> questions;

  const QuizResults({
    Key? key,
    required this.state,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        '${state.correct.length} / ${questions.length}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 60.0,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
      const Text(
        'CORRECT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 40.0),
      CustomButton(
        title: 'New Quiz',
        onTap: () {
          final container = ProviderScope.containerOf(context);
          container.refresh(quizQuestionsProvider);
          container.read(quizControllerProvider.notifier).reset();
        },
      ),
    ],
  );
}

class QuizQuestions extends StatelessWidget {
  final PageController pageController;
  final QuizState state;
  final List<Question> questions;

  const QuizQuestions({
    Key? key,
    required this.pageController,
    required this.state,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => PageView.builder(
    controller: pageController,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: questions.length,
    itemBuilder: (BuildContext context, int index) {
      final question = questions[index];
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Question ${index + 1} of ${questions.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
            child: Text(
              HtmlCharacterEntities.decode(question.question),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Divider(
            color: Colors.grey[200],
            height: 32.0,
            thickness: 2.0,
            indent: 20.0,
            endIndent: 20.0,
          ),
          Column(
            children: question.answer
                .map(
                  (e) => AnswerCard(
                question: question,
                answer: e,
                isSelected: e == state.selectedAnswer,
                isCorrect: e == question.correctAnswer,
                isDisplayingAnswer: state.answered,
              ),
            )
                .toList(),
          ),
        ],
      );
    },
  );
}

class AnswerCard extends ConsumerWidget {
  final Question question;
  final String answer;
  final bool isSelected;
  final bool isCorrect;
  final bool isDisplayingAnswer;

  const AnswerCard({
    Key? key,
    required this.question,
    required this.answer,
    required this.isSelected,
    required this.isCorrect,
    required this.isDisplayingAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (!isDisplayingAnswer) {
          ref.read(quizControllerProvider.notifier).submitAnswer(question, answer);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: boxShadow,
          border: Border.all(
            color: isDisplayingAnswer
                ? (isCorrect
                ? Colors.green
                : isSelected
                ? Colors.red
                : Colors.white)
                : Colors.white,
            width: 4.0,
          ),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                HtmlCharacterEntities.decode(answer),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight:
                  isDisplayingAnswer && isCorrect ? FontWeight.bold : FontWeight.w400,
                ),
              ),
            ),
            if (isDisplayingAnswer)
              isCorrect
                  ? const CircularIcon(icon: Icons.check, color: Colors.green)
                  : isSelected
                  ? const CircularIcon(icon: Icons.close, color: Colors.red)
                  : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class CircularIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const CircularIcon({
    Key? key,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
    height: 24.0,
    width: 24.0,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: boxShadow,
    ),
    child: Icon(
      icon,
      color: Colors.white,
      size: 16.0,
    ),
  );
}

// Your FutureProvider that fetches quiz questions
final quizQuestionsProvider = FutureProvider.autoDispose<List<Question>>(
      (ref) => ref
      .watch(quizRepositoryProvider)
      .getQuestions(
    numQuestions: 5,
    categoryId: Random().nextInt(24) + 9,
    difficulty: Difficulty.any,
  ),
);
