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
      // Fallback questions if asset loading fails
      _loadFallbackQuestions();
      isLoaded = true;
    }
  }

  void startNewGame(int count) {
    selectedTotalCount = count;
    currentQuestionIndex = 0;
    completedCount = 0;
    forfeitedCount = 0;

    final shuffled = List<QuestionItem>.from(allQuestions)..shuffle(Random());
    final effectiveCount = min(count, shuffled.length);
    sessionQuestions = shuffled.take(effectiveCount).toList();
  }

  bool get hasMoreQuestions => currentQuestionIndex < sessionQuestions.length;

  QuestionItem? getNextQuestion() {
    if (!hasMoreQuestions) return null;
    final q = sessionQuestions[currentQuestionIndex];
    return q;
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
    return categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => QuestionCategory(
        id: categoryId,
        name: 'Topshiriq',
        count: 0,
      ),
    );
  }

  void _loadFallbackQuestions() {
    allQuestions = [
      const QuestionItem(
        id: 'fb_1',
        type: 'challenge',
        categoryId: 'quick',
        title: 'Hayvonlar: tezkor ro\'yxat',
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
        type: 'challenge',
        categoryId: 'funny',
        title: 'Robot rejimi',
        description: '20 soniya davomida robot kabi gapir va har bir gapdan keyin kichik robot tovushini qo\'sh.',
        duration: 20,
        timeLimit: true,
        difficulty: 'easy',
        players: 'single',
        tags: ['funny', 'acting'],
        language: 'uz',
        isActive: true,
      ),
      const QuestionItem(
        id: 'fb_3',
        type: 'question',
        categoryId: 'question',
        title: 'Qiziqarli savol',
        description: 'Agar bir kun mashhur ixtirochi bo\'lsang, nimani yaratarding? Sababini ham ayt.',
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

