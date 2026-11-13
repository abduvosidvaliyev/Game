import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../services/sound_service.dart';
import '../widgets/touch_canvas.dart';
import 'challenge_screen.dart';
import 'game_over_screen.dart';

class GotchaGameScreen extends StatefulWidget {
  const GotchaGameScreen({super.key});

  @override
  State<GotchaGameScreen> createState() => _GotchaGameScreenState();
}

class _GotchaGameScreenState extends State<GotchaGameScreen> with SingleTickerProviderStateMixin {
  final QuestionService _questionService = QuestionService();
  final SoundService _soundService = SoundService();

  final Map<int, TouchPoint> _touches = {};
  int? _selectedPointerId;
  double _holdProgress = 0.0;
  Timer? _holdTimer;
  final List<BurstParticle> _particles = [];

  late AnimationController _animController;
  final Random _random = Random();

  static const List<Color> _neonPalette = [
    Color(0xFF00F0FF), // Cyan
    Color(0xFFFF007F), // Neon Pink
    Color(0xFF00FF87), // Bright Green
    Color(0xFFFFBE0B), // Neon Gold
    Color(0xFF9D00FF), // Electric Purple
    Color(0xFFFF5252), // Bright Coral
    Color(0xFF00D2FF), // Sky Blue
    Color(0xFFFF3366), // Hot Red
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Color _getNextColor() {
    final usedColors = _touches.values.map((t) => t.color).toSet();
    for (final color in _neonPalette) {
      if (!usedColors.contains(color)) return color;
    }
    return _neonPalette[_random.nextInt(_neonPalette.length)];
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_selectedPointerId != null) return; // already selected winner

    setState(() {
      _touches[event.pointer] = TouchPoint(
        id: event.pointer,
        position: event.localPosition,
        color: _getNextColor(),
      );
    });

    _soundService.playTouchDown();
    _checkHoldState();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_touches.containsKey(event.pointer)) {
      setState(() {
        _touches[event.pointer]!.position = event.localPosition;
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_selectedPointerId != null) return;

    setState(() {
      _touches.remove(event.pointer);
    });
    _checkHoldState();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_selectedPointerId != null) return;

    setState(() {
      _touches.remove(event.pointer);
    });
    _checkHoldState();
  }

  void _checkHoldState() {
    if (_touches.length >= 2) {
      if (_holdTimer == null) {
        _startHoldCountdown();
      }
    } else {
      _resetHoldCountdown();
    }
  }

  void _startHoldCountdown() {
    _holdTimer?.cancel();
    _holdProgress = 0.0;

    const totalDurationMs = 2400; // 2.4 seconds hold to choose
    const stepMs = 30;
    int elapsedMs = 0;

    _holdTimer = Timer.periodic(const Duration(milliseconds: stepMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      elapsedMs += stepMs;
      setState(() {
        _holdProgress = (elapsedMs / totalDurationMs).clamp(0.0, 1.0);
      });

      if (elapsedMs % 400 == 0) {
        _soundService.playTimerTick();
      }

      if (elapsedMs >= totalDurationMs) {
        timer.cancel();
        _chooseRandomWinner();
      }
    });
  }

  void _resetHoldCountdown() {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (mounted) {
      setState(() {
        _holdProgress = 0.0;
      });
    }
  }

  void _chooseRandomWinner() {
    if (_touches.isEmpty) return;

    final keys = _touches.keys.toList();
    final chosenId = keys[_random.nextInt(keys.length)];
    final winnerTouch = _touches[chosenId]!;

    _soundService.playWinnerSelected();

    // Generate burst particles around the winner
    _particles.clear();
    for (int i = 0; i < 40; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 2.0 + _random.nextDouble() * 7.0;
      _particles.add(
        BurstParticle(
          position: winnerTouch.position,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          color: winnerTouch.color,
          radius: 3.0 + _random.nextDouble() * 5.0,
          opacity: 1.0,
        ),
      );
    }

    setState(() {
      _selectedPointerId = chosenId;
    });

    // Particle animation step
    Timer.periodic(const Duration(milliseconds: 16), (particleTimer) {
      if (!mounted || particleTimer.tick > 45) {
        particleTimer.cancel();
        return;
      }
      setState(() {
        for (final p in _particles) {
          p.position += p.velocity;
          p.opacity -= 0.022;
        }
      });
    });

    // Wait 1.3s and open challenge screen
    Timer(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      _openChallenge();
    });
  }

  void _openChallenge() {
    final question = _questionService.getNextQuestion();
    if (question == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameOverScreen()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeScreen(
          question: question,
          onRoundFinished: () {
            setState(() {
              _touches.clear();
              _selectedPointerId = null;
              _holdProgress = 0.0;
              _particles.clear();
            });

            if (!_questionService.hasMoreQuestions) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GameOverScreen()),
              );
            }
          },
        ),
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00F0FF), width: 1.5),
        ),
        title: const Text(
          'O\'yindan chiqish',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bosh menyuga qaytmoqchimisiz? Hozirgi o\'yin natijalari bekor qilinadi.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Davom etish', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3366),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to start screen
            },
            child: const Text('Ha, chiqish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questionService.currentQuestionIndex + 1;
    final totalQ = _questionService.sessionQuestions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Custom multi-touch interactive canvas
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: TouchCanvasPainter(
                      touches: _touches,
                      holdProgress: _holdProgress,
                      selectedPointerId: _selectedPointerId,
                      particles: _particles,
                      animationValue: _animController.value,
                    ),
                  );
                },
              ),
            ),

            // Top Status Bar (Safe Area)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Home / Exit button
                    IconButton(
                      icon: const Icon(Icons.home_outlined, color: Colors.white70, size: 28),
                      onPressed: _confirmExit,
                      tooltip: 'Bosh menyu',
                    ),

                    // Round / Question Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131726).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F0FF).withOpacity(0.2),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Text(
                        'Savol: $currentQ / $totalQ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Touch Count Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B2E).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app, color: Color(0xFF00FF87), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${_touches.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hint / Instructions Banner at bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1322).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedPointerId != null
                            ? const Color(0xFF00FF87)
                            : _touches.length >= 2
                                ? const Color(0xFFFF007F)
                                : Colors.white12,
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      _selectedPointerId != null
                          ? '🎉 Shart bajaruvchi aniqlandi!'
                          : _touches.length >= 2
                              ? '⚡ Ushlab turing... Tanlanmoqda!'
                              : _touches.length == 1
                                  ? 'Yana bitta barmoq bosing (kamida 2 kishi)'
                                  : 'Barmoqlaringizni ekranga bosing va ushlab turing',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedPointerId != null
                            ? const Color(0xFF00FF87)
                            : _touches.length >= 2
                                ? const Color(0xFFFF007F)
                                : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

