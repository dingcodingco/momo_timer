import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/timer_screen.dart';
import 'services/analytics_service.dart';
import 'services/crashlytics_service.dart';

void main() async {
  // runZonedGuarded로 전체 앱을 감싸서 모든 Dart 오류를 포착
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Firebase 초기화
      await Firebase.initializeApp();

      // Firebase Crashlytics 포괄적 오류 처리 설정
      await _setupCrashlyticsErrorHandling();

      // Firebase Analytics: 앱 시작 이벤트
      await AnalyticsService.logAppOpen();

      // 시스템 UI 설정
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      // 앱 시작
      runApp(const MomoApp());
    },
    (error, stack) {
      // runZonedGuarded에서 포착된 모든 오류 처리
      _handleZoneError(error, stack);
    },
  );
}

/// Firebase Crashlytics 포괄적 오류 처리 설정
Future<void> _setupCrashlyticsErrorHandling() async {
  // 1. Flutter 위젯 오류 처리 (FlutterError.onError)
  FlutterError.onError = (FlutterErrorDetails errorDetails) {
    if (kDebugMode) {
      // 디버그 모드에서는 콘솔에도 출력
      FlutterError.presentError(errorDetails);
      debugPrint('🔴 Flutter Error: ${errorDetails.exceptionAsString()}');
      debugPrint('🔴 Stack trace: ${errorDetails.stack}');
    }

    // Crashlytics에 Flutter 오류 보고
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);

    // 추가 컨텍스트 정보 로깅
    CrashlyticsService.log('Flutter Error occurred: ${errorDetails.library}');
  };

  // 2. 플랫폼 오류 처리 (PlatformDispatcher.instance.onError)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('🔴 Platform Error: $error');
      debugPrint('🔴 Stack trace: $stack');
    }

    // Crashlytics에 플랫폼 오류 보고
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

    // 추가 컨텍스트 정보 로깅
    CrashlyticsService.log('Platform Error occurred: ${error.runtimeType}');

    return true; // 오류 처리 완료를 알림
  };

  // 3. Isolate 오류 처리 (백그라운드 계산 등의 오류)
  Isolate.current.addErrorListener(
    RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      final error = errorAndStacktrace.first;
      final stack = StackTrace.fromString(errorAndStacktrace.last);

      if (kDebugMode) {
        debugPrint('🔴 Isolate Error: $error');
        debugPrint('🔴 Stack trace: $stack');
      }

      // Crashlytics에 Isolate 오류 보고
      await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

      // 추가 컨텍스트 정보 로깅
      await CrashlyticsService.log(
        'Isolate Error occurred: ${error.runtimeType}',
      );
    }).sendPort,
  );

  // 4. 앱 정보 및 컨텍스트 설정
  await _setCrashlyticsContext();
}

/// Zone에서 포착된 오류 처리
void _handleZoneError(Object error, StackTrace stack) {
  if (kDebugMode) {
    debugPrint('🔴 Zone Error: $error');
    debugPrint('🔴 Stack trace: $stack');
  }

  // Crashlytics에 Zone 오류 보고
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

  // 추가 컨텍스트 정보 로깅
  CrashlyticsService.log('Zone Error occurred: ${error.runtimeType}');
}

/// Crashlytics 초기 컨텍스트 설정
Future<void> _setCrashlyticsContext() async {
  try {
    // 앱 버전 정보 설정
    const appVersion = '1.1.0'; // pubspec.yaml의 version과 동기화
    await CrashlyticsService.setUserProperties(appVersion: appVersion);

    // 앱 시작 시간 설정
    await CrashlyticsService.setCustomKey(
      'app_start_time',
      DateTime.now().toIso8601String(),
    );

    // 플랫폼 정보 설정
    await CrashlyticsService.setCustomKey(
      'platform',
      defaultTargetPlatform.name,
    );

    // 디버그/릴리즈 모드 설정
    await CrashlyticsService.setCustomKey('debug_mode', kDebugMode);

    // 첫 실행 여부 확인 (추후 SharedPreferences로 확장 가능)
    await CrashlyticsService.setAppContext(
      screenName: 'app_startup',
      isFirstLaunch: true, // 실제로는 SharedPreferences에서 확인
    );

    if (kDebugMode) {
      debugPrint('✅ Crashlytics context initialized');
    }
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('⚠️ Failed to set Crashlytics context: $e');
    }
    // 컨텍스트 설정 실패도 보고
    FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
  }
}

class MomoApp extends StatelessWidget {
  const MomoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MOMO Timer',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: TimerScreen(themeProvider: themeProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
