import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// 사용자 식별자 설정 (개인정보는 설정하지 않음)
  static Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  /// 커스텀 키-값 데이터 설정
  static Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// 사용자 속성 설정 (앱 버전, 설정 등)
  static Future<void> setUserProperties({
    String? appVersion,
    bool? isDarkMode,
    int? totalSessions,
    int? streakCount,
  }) async {
    if (appVersion != null) {
      await _crashlytics.setCustomKey('app_version', appVersion);
    }
    if (isDarkMode != null) {
      await _crashlytics.setCustomKey('dark_mode', isDarkMode);
    }
    if (totalSessions != null) {
      await _crashlytics.setCustomKey('total_sessions', totalSessions);
    }
    if (streakCount != null) {
      await _crashlytics.setCustomKey('streak_count', streakCount);
    }
  }

  /// 비치명적 오류 로깅
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// 커스텀 로그 메시지 추가
  static Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// 타이머 관련 크래시 컨텍스트
  static Future<void> setTimerContext({
    required bool isRunning,
    required int timeLeft,
    required String sessionType,
  }) async {
    await _crashlytics.setCustomKey('timer_running', isRunning);
    await _crashlytics.setCustomKey('timer_time_left', timeLeft);
    await _crashlytics.setCustomKey('timer_session_type', sessionType);
  }

  /// 세션 관련 크래시 컨텍스트
  static Future<void> setSessionContext({
    required int sessionCount,
    required String lastMood,
    required DateTime lastSessionTime,
  }) async {
    await _crashlytics.setCustomKey('session_count_today', sessionCount);
    await _crashlytics.setCustomKey('last_mood', lastMood);
    await _crashlytics.setCustomKey(
      'last_session_time',
      lastSessionTime.toIso8601String(),
    );
  }

  /// 앱 상태 관련 컨텍스트
  static Future<void> setAppContext({
    required String screenName,
    required bool isFirstLaunch,
  }) async {
    await _crashlytics.setCustomKey('current_screen', screenName);
    await _crashlytics.setCustomKey('is_first_launch', isFirstLaunch);
  }

  /// 테스트용 크래시 발생 (디버그 전용)
  static void testCrash() {
    _crashlytics.crash();
  }

  /// Crashlytics 수집 활성화/비활성화
  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  /// 크래시 리포팅 상태 확인
  static bool get isCrashlyticsCollectionEnabled {
    return _crashlytics.isCrashlyticsCollectionEnabled;
  }
}
