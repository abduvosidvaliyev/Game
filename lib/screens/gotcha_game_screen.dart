import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../services/sound_service.dart';
import 'challenge_screen.dart';

class TouchPoint {
  final int id;
  Offset position;
  final Color color;
  TouchPoint({required this.id, required this.position, required this.color});
}

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

  // Full-screen expansion transition
  bool _isExpanding = false;
  double _expandRadius = 0.0;
  double _expandOpacity = 1.0;
  Color _winnerColor = const Color(0xFF7C5CFC);
  Offset _winnerPos = Offset.zero;

  late AnimationController _pulseController;
  final Random _random = Random();
  int _colorOffset = 0;

  static const List<Color> _palette = [
    Color(0xFFFF4B6E), // coral red
    Color(0xFF7C5CFC), // violet
    Color(0xFF3DDC84), // green
    Color(0xFFFFBE0B), // amber
    Color(0xFF00C6FF), // sky blue
    Color(0xFFFF7A00), // orange
    Color(0xFFE040FB), // magenta
    Color(0xFF00E5FF), // cyan
    Color(0xFF76FF03), // lime
    Color(0xFFFF4081), // pink
    Color(0xFFF9A8D4), // rose
    Color(0xFF34D399), // emerald
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getNextColor() {
    final usedColors = _touches.values.map((t) => t.color).toSet();
    for (int i = 0; i < _palette.length; i++) {
      final c = _palette[(_colorOffset + i) % _palette.length];
      if (!usedColors.contains(c)) {
        _colorOffset = (_colorOffset + i + 1) % _palette.length;
        return c;
      }
    }
    // Agar 12 tadan ham ko'p barmoq qo'yilsa, avtomatik ravishda cheksiz yorqin yangi rang generatsiya qiladi!
    final hue = (_touches.length * 137.5) % 360.0; // Oltin burchak bo'yicha to'qnashmaydigan rang
    return HSLColor.fromAHSL(1.0, hue, 0.85, 0.60).toColor();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_selectedPointerId != null) return;

    setState(() {
      _touches[event.pointer] = TouchPoint(
        id: event.pointer,
        position: event.position,
        color: _getNextColor(),
      );
    });

    _soundService.playPop();
    _checkHold();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_touches.containsKey(event.pointer)) {
      setState(() {
        _touches[event.pointer]!.position = event.position;
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_selectedPointerId != null) return;
    setState(() {
      _touches.remove(event.pointer);
    });
    _checkHold();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_selectedPointerId != null) return;
    setState(() {
      _touches.remove(event.pointer);
    });
    _checkHold();
  }

  void _checkHold() {
    if (_selectedPointerId != null) return;

    if (_touches.length >= 2) {
      if (_holdTimer == null) _startHold();
    } else {
      _resetHold();
    }
  }

  void _startHold() {
    _holdProgress = 0.0;
    const totalDuration = 2200; // ms
    const step = 30; // ms
    int elapsed = 0;

    _holdTimer = Timer.periodic(const Duration(milliseconds: step), (timer) {
      elapsed += step;
      setState(() {
        _holdProgress = (elapsed / totalDuration).clamp(0.0, 1.0);
      });

      if (elapsed % 300 == 0) {
        _soundService.playTick();
      }

      if (elapsed >= totalDuration) {
        timer.cancel();
        _holdTimer = null;
        _chooseWinner();
      }
    });
  }

  void _resetHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    setState(() {
      _holdProgress = 0.0;
    });
  }

  void _chooseWinner() {
    if (_touches.isEmpty) return;

    final keys = _touches.keys.toList();
    _selectedPointerId = keys[_random.nextInt(keys.length)];
    final winner = _touches[_selectedPointerId]!;

    _soundService.playWinner();

    final size = MediaQuery.of(context).size;
    final maxDist = max(
      max(winner.position.dx, size.width - winner.position.dx),
      max(winner.position.dy, size.height - winner.position.dy),
    ) * 1.5;

    setState(() {
      _isExpanding = true;
      _winnerColor = winner.color;
      _winnerPos = winner.position;
      _expandRadius = 45.0;
      _expandOpacity = 1.0;
    });

    // Animate wave expansion
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _expandRadius += (maxDist - _expandRadius) * 0.12;
        if (_expandRadius > maxDist * 0.4) {
          _expandOpacity = max(0.0, _expandOpacity - 0.04);
        }
      });

      if (_expandOpacity <= 0.01) {
        timer.cancel();
      }
    });

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      final currentQuestion = _questionService.currentQuestion;
      if (currentQuestion != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeScreen(
              question: currentQuestion,
              winnerColor: winner.color,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: Stack(
          children: [
            // Custom Painter for all touch circles and full-screen winner wave
            CustomPaint(
              size: size,
              painter: _TouchPainter(
                touches: _touches.values.toList(),
                selectedId: _selectedPointerId,
                pulseValue: _pulseController.value,
                isExpanding: _isExpanding,
                expandRadius: _expandRadius,
                expandOpacity: _expandOpacity,
                winnerColor: _winnerColor,
                winnerPos: _winnerPos,
              ),
            ),

            // Top Header: Home Button & Question counter
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF16161F),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            title: const Text('Bosh menyuga qaytasizmi?', style: TextStyle(fontWeight: FontWeight.w900)),
                            content: const Text('O\'yin tarixingiz o\'chib ketadi', style: TextStyle(color: Color(0xFF6B6B8A))),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Yo\'q', style: TextStyle(color: Color(0xFF6B6B8A), fontWeight: FontWeight.w800)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF4B6E),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Navigator.pop(context);
                                },
                                child: const Text('Ha, qaytish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16161F).withOpacity(0.85),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161F).withOpacity(0.85),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TouchPainter extends CustomPainter {
  final List<TouchPoint> touches;
  final int? selectedId;
  final double pulseValue;
  final bool isExpanding;
  final double expandRadius;
  final double expandOpacity;
  final Color winnerColor;
  final Offset winnerPos;

  _TouchPainter({
    required this.touches,
    required this.selectedId,
    required this.pulseValue,
    required this.isExpanding,
    required this.expandRadius,
    required this.expandOpacity,
    required this.winnerColor,
    required this.winnerPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw winner expanding circular wave
    if (isExpanding && expandOpacity > 0.0) {
      final expandPaint = Paint()
        ..color = winnerColor.withOpacity(expandOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(winnerPos, expandRadius, expandPaint);
    }

    // 2. Draw active finger touch circles
    for (final touch in touches) {
      if (isExpanding && touch.id != selectedId) continue;

      final isSelected = touch.id == selectedId;
      final pulse = pulseValue * 6.0;
      final radius = isSelected ? 46.0 : 38.0;

      // Soft glow
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            touch.color.withOpacity(0.35),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: touch.position, radius: radius + 40 + pulse));
      canvas.drawCircle(touch.position, radius + 40 + pulse, glowPaint);

      // Outer Ring
      final ringPaint = Paint()
        ..color = touch.color.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(touch.position, radius + 12 + pulse, ringPaint);

      // Core Solid Circle
      final corePaint = Paint()
        ..color = isSelected ? Colors.white : touch.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(touch.position, radius, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TouchPainter oldDelegate) => true;
}
