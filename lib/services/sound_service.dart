import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _popPlayer = AudioPlayer();
  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _winnerPlayer = AudioPlayer();

  Future<void> init() async {
    try {
      await _popPlayer.setSource(AssetSource('audio/bubble_pop.mp3'));
      await _tickPlayer.setSource(AssetSource('audio/tick.mp3'));
      await _winnerPlayer.setSource(AssetSource('audio/winner.mp3'));
    } catch (_) {}
  }

  void playPop() {
    try {
      HapticFeedback.lightImpact();
      _popPlayer.stop();
      _popPlayer.play(AssetSource('audio/bubble_pop.mp3'), volume: 0.7);
    } catch (_) {}
  }

  void playTick() {
    try {
      HapticFeedback.selectionClick();
      _tickPlayer.stop();
      _tickPlayer.play(AssetSource('audio/tick.mp3'), volume: 0.4);
    } catch (_) {}
  }

  void playWinner() {
    try {
      HapticFeedback.heavyImpact();
      _winnerPlayer.stop();
      _winnerPlayer.play(AssetSource('audio/winner.mp3'), volume: 0.9);
    } catch (_) {}
  }
}
