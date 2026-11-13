import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool soundEnabled = true;
  bool hapticsEnabled = true;

  void playTouchDown() {
    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void playTimerTick() {
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void playWinnerSelected() {
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    SystemSound.play(SystemSoundType.click);
  }

  void playTimerDone() {
    if (hapticsEnabled) {
      HapticFeedback.vibrate();
    }
    SystemSound.play(SystemSoundType.alert);
  }

  void playSuccess() {
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    SystemSound.play(SystemSoundType.click);
  }

  void playFail() {
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}

