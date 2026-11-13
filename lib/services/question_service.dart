import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionService {
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;
  QuestionService._internal();

  List<QuestionCategory> categories = [];
  List<QuestionItem> allQuestions = [];

  // Current game session
  int selectedTotalCount = 20;
  List<QuestionItem> sessionQuestions = [];
  int currentQuestionIndex = 0;

  int get currentIndex => currentQuestionIndex;
  int get totalCount => sessionQuestions.length;
  QuestionItem? get currentQuestion =>
      currentQuestionIndex < sessionQuestions.length ? sessionQuestions[currentQuestionIndex] : null;

  // Game stats
  int completedCount = 0;
  int forfeitedCount = 0;

  bool isLoaded = false;

  Future<void> loadQuestions() async {
    if (isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/questions.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      if (data['categories'] != null) {
        categories = (data['categories'] as List)
            .map((cat) => QuestionCategory.fromJson(cat))
            .toList();
      }

      if (data['data'] != null) {
        allQuestions = (data['data'] as List)
            .map((item) => QuestionItem.fromJson(item))
            .where((item) => item.isActive)
            .toList();
      }

      isLoaded = true;
    } catch (e) {
      _loadFallbackQuestions();
      isLoaded = true;
    }
  }

  void startSession(int count) {
    selectedTotalCount = count;
    currentQuestionIndex = 0;
    completedCount = 0;
    forfeitedCount = 0;

    final shuffled = List<QuestionItem>.from(allQuestions)..shuffle(Random());
    final effectiveCount = min(count, shuffled.length);
    sessionQuestions = shuffled.take(effectiveCount).toList();
  }

  void startNewGame(int count) => startSession(count);

  bool get hasMoreQuestions => currentQuestionIndex < sessionQuestions.length;

  QuestionItem? nextQuestion() {
    currentQuestionIndex++;
    if (currentQuestionIndex < sessionQuestions.length) {
      return sessionQuestions[currentQuestionIndex];
    }
    return null;
  }

  QuestionItem? getNextQuestion() {
    if (!hasMoreQuestions) return null;
    return sessionQuestions[currentQuestionIndex];
  }

  void advanceQuestion({required bool completed}) {
    if (completed) {
      completedCount++;
    } else {
      forfeitedCount++;
    }
    currentQuestionIndex++;
  }

  QuestionCategory? getCategoryFor(String categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  void _loadFallbackQuestions() {
    allQuestions = [
      const QuestionItem(
        id: 'fb_1',
        type: 'challenge',
        categoryId: 'quick',
        title: 'Hayvonlar ro\'yxati',
        description: '20 soniya ichida 9 ta hayvonlar nomini ayt. Bir xil javobni takrorlama.',
        duration: 20,
        timeLimit: true,
        difficulty: 'medium',
        players: 'single',
        tags: ['quick', 'memory'],
        language: 'uz',
        isActive: true,
      ),
      const QuestionItem(
        id: 'fb_2',
        type: 'question',
        categoryId: 'question',
        title: 'Qiziqarli savol',
        description: 'Qaysi film yoki kitob senga kuchli taassurot qoldirgan? Sababini ayt.',
        duration: null,
        timeLimit: false,
        difficulty: 'easy',
        players: 'single',
        tags: ['question', 'friends'],
        language: 'uz',
        isActive: true,
      ),
    ];
  }
}
