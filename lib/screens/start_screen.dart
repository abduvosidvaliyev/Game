import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../widgets/neon_button.dart';
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

  void _showCustomCountDialog() {
    final textController = TextEditingController(text: _selectedCount.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141824),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF00F0FF), width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.tune, color: Color(0xFF00F0FF)),
              SizedBox(width: 10),
              Text(
                'Savollar sonini kiriting',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Davra uchun qulay bo\'lgan istalgan sonni kiriting (5 dan 100 gacha):',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Masalan: 15, 25, 40...',
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 16),
                  filled: true,
                  fillColor: const Color(0xFF1E2337),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00F0FF), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF007F), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F0FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final parsed = int.tryParse(textController.text.trim());
                if (parsed != null && parsed >= 3 && parsed <= 200) {
                  setState(() {
                    _selectedCount = parsed;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Iltimos, 3 dan 200 gacha son kiriting!'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('Tasdiqlash', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _startGame() {
    _questionService.startNewGame(_selectedCount);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GotchaGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const predefinedCounts = [20, 30, 50];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const Spacer(),

                    // Neon Gotcha Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00F0FF), Color(0xFFFF007F)],
                      ).createShader(bounds),
                      child: const Text(
                        'GOTCHA',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Davralar uchun random shartlar',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Question prompt container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131726),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF00F0FF).withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F0FF).withOpacity(0.08),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'O\'yin nechta savolli bo\'lsin?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Barcha savollar takrorlanmas va random tanlanadi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 4 Choices: 20, 30, 50, Boshqa...
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              ...predefinedCounts.map((count) {
                                final isSelected = _selectedCount == count;
                                return _buildCountChip(
                                  label: '$count ta',
                                  subLabel: count == 20
                                      ? 'Tezkor'
                                      : count == 30
                                          ? 'Standart'
                                          : 'Katta davra',
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      _selectedCount = count;
                                    });
                                  },
                                );
                              }),
                              _buildCountChip(
                                label: !predefinedCounts.contains(_selectedCount)
                                    ? '$_selectedCount ta'
                                    : 'Boshqa...',
                                subLabel: !predefinedCounts.contains(_selectedCount)
                                    ? 'Maxsus'
                                    : 'O\'zingiz tanlang',
                                isSelected: !predefinedCounts.contains(_selectedCount),
                                isCustom: true,
                                onTap: _showCustomCountDialog,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Start Game Button
                    NeonButton(
                      text: 'O\'yinni boshlash',
                      icon: Icons.play_arrow_rounded,
                      color: const Color(0xFF00FF87),
                      height: 60,
                      width: double.infinity,
                      onPressed: _startGame,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCountChip({
    required String label,
    required String subLabel,
    required bool isSelected,
    required VoidCallback onTap,
    bool isCustom = false,
  }) {
    final activeColor = isCustom ? const Color(0xFFFF007F) : const Color(0xFF00F0FF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 135,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.18) : const Color(0xFF1B2033),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white12,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subLabel,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

