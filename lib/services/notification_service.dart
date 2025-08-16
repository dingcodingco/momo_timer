import 'package:vibration/vibration.dart';

class NotificationService {
  static Future<void> playCompletionFeedback() async {
    // 진동 패턴 (짧게-길게-짧게)
    await Vibration.vibrate(pattern: [0, 100, 50, 200, 50, 100]);
  }

  static Future<void> playTickFeedback() async {
    // 가벼운 진동
    await Vibration.vibrate(duration: 10);
  }

  static Future<void> playStartFeedback() async {
    // 시작 시 간단한 진동
    await Vibration.vibrate(duration: 50);
  }
}
