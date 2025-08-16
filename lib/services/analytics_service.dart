import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // 화면 추적
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // 세션 시작 이벤트
  static Future<void> logSessionStart({
    required String sessionType, // 'focus' or 'break'
  }) async {
    await _analytics.logEvent(
      name: 'session_start',
      parameters: {'session_type': sessionType},
    );
  }

  // 세션 완료 이벤트
  static Future<void> logSessionComplete({
    required String sessionType,
    required int duration, // seconds
    required String mood,
  }) async {
    await _analytics.logEvent(
      name: 'session_complete',
      parameters: {
        'session_type': sessionType,
        'duration_seconds': duration,
        'mood': mood,
      },
    );
  }

  // 스트릭 달성 이벤트
  static Future<void> logStreakAchieved(int streakCount) async {
    await _analytics.logEvent(
      name: 'streak_achieved',
      parameters: {'streak_count': streakCount},
    );
  }

  // 앱 설정 변경 이벤트
  static Future<void> logSettingChanged({
    required String settingName,
    required dynamic value,
  }) async {
    await _analytics.logEvent(
      name: 'setting_changed',
      parameters: {'setting_name': settingName, 'value': value.toString()},
    );
  }

  // 사용자 속성 설정
  static Future<void> setUserProperties({
    int? totalSessions,
    int? currentStreak,
    String? preferredTheme,
  }) async {
    if (totalSessions != null) {
      await _analytics.setUserProperty(
        name: 'total_sessions',
        value: totalSessions.toString(),
      );
    }

    if (currentStreak != null) {
      await _analytics.setUserProperty(
        name: 'current_streak',
        value: currentStreak.toString(),
      );
    }

    if (preferredTheme != null) {
      await _analytics.setUserProperty(
        name: 'preferred_theme',
        value: preferredTheme,
      );
    }
  }

  // 앱 실행 이벤트
  static Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }
}
