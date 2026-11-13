import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../widgets/neon_button.dart';
import 'gotcha_game_screen.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = QuestionService();
    final total = service.sessionQuestions.length;
    final completed = service.completedCount;
    final forfeited = service.forfeitedCount;

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Trophy / Game over icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00FF87).withOpacity(0.12),
                  border: Border.all(color: const Color(0xFF00FF87), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF87).withOpacity(0.4),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFF00FF87),
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'O\'YIN YAKUNLANDI!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Barcha $total ta shart va savollar muvaffaqiyatli yakunlandi',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 36),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'Bajarildi',
                      value: '$completed',
                      color: const Color(0xFF00FF87),
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Yutqazildi',
                      value: '$forfeited',
                      color: const Color(0xFFFF3366),
                      icon: Icons.cancel_outlined,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Replay button
              NeonButton(
                text: 'Qaytadan o\'ynash ($total ta)',
                icon: Icons.replay,
                color: const Color(0xFF00FF87),
                height: 56,
                width: double.infinity,
                onPressed: () {
                  service.startNewGame(total);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const GotchaGameScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Main menu button
              NeonButton(
                text: 'Bosh menyuga qaytish',
                icon: Icons.home_rounded,
                color: const Color(0xFF00F0FF),
                isOutlined: true,
                height: 56,
                width: double.infinity,
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131728),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: color.withOpacity(0.8), blurRadius: 12),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

