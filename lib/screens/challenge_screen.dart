import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../services/sound_service.dart';
import 'game_over_screen.dart';
import 'gotcha_game_screen.dart';

class ChallengeScreen extends StatefulWidget {
  final QuestionItem question;
  final Color winnerColor;

  const ChallengeScreen({
    super.key,
    required this.question,
    required this.winnerColor,
  });

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final QuestionService _questionService = QuestionService();
  final SoundService _soundService = SoundService();

  bool _isTimerStarted = false;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.question.duration ?? 30;
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
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
        _soundService.playTick();
      } else {
        timer.cancel();
        _soundService.playTick();
        setState(() {
          _remainingSeconds = 0;
          _isFinished = true;
        });
      }
    });
  }

  void _onDone() {
    _timer?.cancel();
    _soundService.playWinner();
    setState(() {
      _isFinished = true;
    });
  }

  void _onFail() {
    _timer?.cancel();
    _soundService.playPop();
    setState(() {
      _isFinished = true;
    });
  }

  void _nextRound() {
    final next = _questionService.nextQuestion();
    if (next != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GotchaGameScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameOverScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTimed = widget.question.timeLimit && (widget.question.duration ?? 0) > 0;
    final catColor = widget.question.categoryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _timer?.cancel();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const GotchaGameScreen()),
                      );
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161F),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161F),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      '${_questionService.currentIndex + 1} / ${_questionService.totalCount}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF0F0FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Winner Ring Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: widget.winnerColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: widget.winnerColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.winnerColor.withOpacity(0.5),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.star_rounded, color: Colors.white, size: 32),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'SHART BAJARUVCHI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: Color(0xFF6B6B8A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Challenge Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16161F),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.07)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: catColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(widget.question.categoryIcon, size: 14, color: catColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.question.categoryNameUz.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: catColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              widget.question.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFF0F0FF),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              widget.question.description,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                                color: const Color(0xFFF0F0FF).withOpacity(0.85),
                              ),
                            ),

                            if (isTimed && !_isTimerStarted && !_isFinished) ...[
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7C5CFC),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: _startTimer,
                                  child: Text(
                                    '▶ Shartni boshlash (${widget.question.duration}s)',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],

                            if (isTimed && _isTimerStarted) ...[
                              const SizedBox(height: 20),
                              Center(
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF7C5CFC), width: 5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$_remainingSeconds',
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Action Buttons
              if (!_isFinished)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: const BorderSide(color: Color(0xFFFF4B6E), width: 2),
                          backgroundColor: const Color(0xFFFF4B6E).withOpacity(0.08),
                        ),
                        onPressed: _onFail,
                        child: const Text('✕ Yutqazdim', style: TextStyle(color: Color(0xFFFF4B6E), fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: const BorderSide(color: Color(0xFF3DDC84), width: 2),
                          backgroundColor: const Color(0xFF3DDC84).withOpacity(0.08),
                        ),
                        onPressed: _onDone,
                        child: const Text('✓ Tugatdim', style: TextStyle(color: Color(0xFF3DDC84), fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E2D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: Colors.white10),
                    ),
                    onPressed: _nextRound,
                    child: const Text('O\'yinga qaytish ↩', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
