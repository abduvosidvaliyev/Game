import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../services/sound_service.dart';
import '../widgets/neon_button.dart';

class ChallengeScreen extends StatefulWidget {
  final QuestionItem question;
  final VoidCallback onRoundFinished;

  const ChallengeScreen({
    super.key,
    required this.question,
    required this.onRoundFinished,
  });

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final QuestionService _questionService = QuestionService();
  final SoundService _soundService = SoundService();

  bool _isTimerStarted = false;
  bool _isFinished = false;
  bool _isSuccess = false;
  int _remainingSeconds = 0;
  int _initialDuration = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initialDuration = widget.question.duration ?? (widget.question.timeLimit ? 30 : 0);
    _remainingSeconds = _initialDuration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isTimerStarted = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds > 1) {
          _remainingSeconds--;
          _soundService.playTimerTick();
        } else {
          _remainingSeconds = 0;
          timer.cancel();
          _soundService.playTimerDone();
          _finishTask(completed: true, autoExpired: true);
        }
      });
    });
  }

  void _finishTask({required bool completed, bool autoExpired = false}) {
    _timer?.cancel();

    if (completed) {
      _soundService.playSuccess();
    } else {
      _soundService.playFail();
    }

    _questionService.advanceQuestion(completed: completed);

    setState(() {
      _isFinished = true;
      _isSuccess = completed;
    });

    if (autoExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏰ Vaqt tugadi! Shart yakunlandi.'),
          backgroundColor: Color(0xFF00F0FF),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _returnToGame() {
    widget.onRoundFinished();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final category = _questionService.getCategoryFor(widget.question.categoryId);
    final categoryColor = category?.color ?? const Color(0xFF00F0FF);
    final isTimed = widget.question.timeLimit;
    final currentQ = _questionService.currentQuestionIndex + 1;
    final totalQ = _questionService.sessionQuestions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D18),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: _returnToGame,
          tooltip: 'O\'yinga qaytish',
        ),
        title: Text(
          'Savol $currentQ / $totalQ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // Category badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: categoryColor.withOpacity(0.8), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withOpacity(0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category?.iconData ?? Icons.star, color: categoryColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          category?.name ?? 'Topshiriq',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Difficulty badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.question.difficultyColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.question.difficultyColor.withOpacity(0.6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.question.difficultyUz,
                      style: TextStyle(
                        color: widget.question.difficultyColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Main Question Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131728),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        widget.question.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Description
                      Text(
                        widget.question.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Interactive Timer Section (if timed)
                      if (isTimed) ...[
                        const SizedBox(height: 32),
                        if (!_isTimerStarted && !_isFinished) ...[
                          // Start Timer Button
                          NeonButton(
                            text: 'Shartni boshlash ($_initialDuration soniya)',
                            icon: Icons.timer,
                            color: const Color(0xFF00F0FF),
                            height: 52,
                            onPressed: _startTimer,
                          ),
                        ] else ...[
                          // Animated Countdown Circle
                          _buildTimerDisplay(categoryColor),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons section
              if (!_isFinished) ...[
                // If not finished yet: Show "Tugatdim" and "Yutqazdim"
                // If timed and timer not started yet, user can also directly finish or start timer
                Row(
                  children: [
                    Expanded(
                      child: NeonButton(
                        text: 'Yutqazdim',
                        icon: Icons.close_rounded,
                        color: const Color(0xFFFF3366),
                        height: 54,
                        onPressed: () => _finishTask(completed: false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NeonButton(
                        text: 'Tugatdim',
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF00FF87),
                        height: 54,
                        onPressed: () => _finishTask(completed: true),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Finished state: Success or Failed banner + Return to Game button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? const Color(0xFF00FF87).withOpacity(0.15)
                        : const Color(0xFFFF3366).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isSuccess ? const Color(0xFF00FF87) : const Color(0xFFFF3366),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle : Icons.cancel,
                        color: _isSuccess ? const Color(0xFF00FF87) : const Color(0xFFFF3366),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isSuccess ? 'Shart muvaffaqiyatli bajarildi!' : 'Shart bajarilmadi (yutqazildi)',
                        style: TextStyle(
                          color: _isSuccess ? const Color(0xFF00FF87) : const Color(0xFFFF3366),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                NeonButton(
                  text: 'O\'yinga qaytish (Keyingi raund)',
                  icon: Icons.arrow_forward_rounded,
                  color: const Color(0xFF00F0FF),
                  height: 56,
                  width: double.infinity,
                  onPressed: _returnToGame,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(Color accentColor) {
    final double progress = _initialDuration > 0
        ? (_remainingSeconds / _initialDuration).clamp(0.0, 1.0)
        : 0.0;

    final timerColor = _remainingSeconds <= 5
        ? const Color(0xFFFF3366)
        : const Color(0xFF00F0FF);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_remainingSeconds',
                  style: TextStyle(
                    color: timerColor,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: timerColor.withOpacity(0.6), blurRadius: 15),
                    ],
                  ),
                ),
                const Text(
                  'soniya',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

