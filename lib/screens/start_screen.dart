import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../services/sound_service.dart';
import 'gotcha_game_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final QuestionService _questionService = QuestionService();
  int _selectedCount = 20;
  bool _isLoading = true;
  bool _isCustom = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _questionService.loadQuestions();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCustomDialog() {
    final textController = TextEditingController(text: _selectedCount.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF16161F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Maxsus son',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF0F0FF),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '3 dan 150 gacha son kiriting',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B6B8A),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E2D),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF7C5CFC), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: Colors.white10),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Bekor', style: TextStyle(color: Color(0xFF6B6B8A), fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF7C5CFC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        final val = int.tryParse(textController.text);
                        if (val != null && val >= 3 && val <= 150) {
                          setState(() {
                            _selectedCount = val;
                            _isCustom = true;
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Tasdiqlash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D14),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7C5CFC)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: Stack(
        children: [
          // Background soft glow
          Positioned(
            top: -100,
            left: 50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C5CFC).withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C5CFC), Color(0xFFFC5C9C)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C5CFC).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.casino, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'GOTCHA',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: Color(0xFFF0F0FF),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'RANDOM SHARTLAR O\'YINI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: Color(0xFF6B6B8A),
                        ),
                      ),
                    ],
                  ),

                  // Selection Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161F),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.07)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'NECHTA SAVOLLI BO\'LSIN?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Color(0xFF6B6B8A),
                          ),
                        ),
                        const SizedBox(height: 18),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _buildCountBtn(20, 'Tezkor', const Color(0xFF7C5CFC)),
                            _buildCountBtn(30, 'Standart', const Color(0xFFFC5C9C)),
                            _buildCountBtn(50, 'Katta davra', const Color(0xFF3DDC84)),
                            _buildCustomBtn(),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C5CFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 10,
                        shadowColor: const Color(0xFF7C5CFC).withOpacity(0.5),
                      ),
                      onPressed: () {
                        SoundService().playWinner();
                        _questionService.startSession(_selectedCount);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GotchaGameScreen(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'O\'yinni boshlash',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBtn(int count, String label, Color glowColor) {
    final isSelected = !_isCustom && _selectedCount == count;
    return GestureDetector(
      onTap: () {
        SoundService().playTick();
        setState(() {
          _selectedCount = count;
          _isCustom = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? glowColor.withOpacity(0.15) : const Color(0xFF1E1E2D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? glowColor : Colors.white.withOpacity(0.06),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 15)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFFF0F0FF),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: Color(0xFF6B6B8A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBtn() {
    final isSelected = _isCustom;
    const glowColor = Color(0xFFFFBE0B);
    return GestureDetector(
      onTap: () {
        SoundService().playTick();
        _showCustomDialog();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? glowColor.withOpacity(0.15) : const Color(0xFF1E1E2D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? glowColor : Colors.white.withOpacity(0.06),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 15)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isSelected ? '$_selectedCount' : '✏️',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFFF0F0FF),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'MAXSUS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: Color(0xFF6B6B8A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
