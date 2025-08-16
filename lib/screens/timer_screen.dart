import 'dart:async';
import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../services/analytics_service.dart';
import '../providers/theme_provider.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class TimerScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const TimerScreen({super.key, required this.themeProvider});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  static const int focusDuration = 25 * 60; // 25분
  static const int breakDuration = 5 * 60; // 5분

  Timer? _timer;
  int _timeLeft = focusDuration;
  bool _isRunning = false;
  bool _isFocusSession = true;
  DateTime? _sessionStartTime;
  int _streakCount = 0;
  bool _vibrationEnabled = true;
  int _todaySessionCount = 0;
  int _totalSessionCount = 0;

  // 애니메이션 컨트롤러들
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initAnimations();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadSettings() async {
    final streak = await SettingsService.getStreakCount();
    final vibration = await SettingsService.isVibrationEnabled();
    final sessions = await StorageService.getSessions();

    final today = DateTime.now();
    final todaySessions = sessions.where((session) {
      return session.startTime.year == today.year &&
          session.startTime.month == today.month &&
          session.startTime.day == today.day;
    }).length;

    setState(() {
      _streakCount = streak;
      _vibrationEnabled = vibration;
      _todaySessionCount = todaySessions;
      _totalSessionCount = sessions.length;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _sessionStartTime = DateTime.now();
    });

    // Firebase Analytics: 세션 시작 이벤트
    AnalyticsService.logSessionStart(
      sessionType: _isFocusSession ? 'focus' : 'break',
    );

    // 시작 피드백
    if (_vibrationEnabled) {
      NotificationService.playStartFeedback();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = _isFocusSession ? focusDuration : breakDuration;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    // 완료 피드백
    if (_vibrationEnabled) {
      NotificationService.playCompletionFeedback();
    }

    if (_isFocusSession) {
      // 포커스 세션 완료 - 기분 선택
      _showMoodDialog();
    } else {
      // 휴식 완료 - 다음 포커스 세션으로
      _switchToFocusSession();
    }
  }

  void _showMoodDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '세션 완료! 😊',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text('지금 기분이 어떠신가요?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMoodButton('😊', '좋음'),
                _buildMoodButton('😐', '보통'),
                _buildMoodButton('😞', '안좋음'),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoodButton(String emoji, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _saveMoodAndContinue(emoji),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.grey[100],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _saveMoodAndContinue(String mood) async {
    if (_sessionStartTime != null) {
      final session = Session(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        type: 'focus',
        mood: mood,
      );

      await StorageService.saveSession(session);
      await SettingsService.updateStreak();

      // Firebase Analytics: 세션 완료 이벤트
      final duration = session.endTime.difference(session.startTime).inSeconds;
      await AnalyticsService.logSessionComplete(
        sessionType: 'focus',
        duration: duration,
        mood: mood,
      );

      // 스트릭 및 세션 카운트 업데이트
      final newStreak = await SettingsService.getStreakCount();

      // Firebase Analytics: 스트릭 달성 이벤트
      if (newStreak > _streakCount) {
        await AnalyticsService.logStreakAchieved(newStreak);
      }

      setState(() {
        _streakCount = newStreak;
        _todaySessionCount++;
        _totalSessionCount++;
      });

      // Firebase Analytics: 사용자 속성 업데이트
      await AnalyticsService.setUserProperties(
        totalSessions: _totalSessionCount,
        currentStreak: newStreak,
      );
    }

    Navigator.of(context).pop();
    _switchToBreakSession();
  }

  void _switchToFocusSession() {
    setState(() {
      _isFocusSession = true;
      _timeLeft = focusDuration;
    });
  }

  void _switchToBreakSession() {
    setState(() {
      _isFocusSession = false;
      _timeLeft = breakDuration;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        1.0 - (_timeLeft / (_isFocusSession ? focusDuration : breakDuration));
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    // 반응형 크기 계산
    final timerSize = isTablet ? 360.0 : 240.0;
    final progressSize = isTablet ? 320.0 : 200.0;
    final timerFontSize = isTablet ? 56.0 : 42.0;
    final titleFontSize = isTablet ? 28.0 : 20.0;
    final buttonSize = isTablet ? 90.0 : 70.0;
    final resetButtonSize = isTablet ? 70.0 : 50.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MOMO'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsScreen(themeProvider: widget.themeProvider),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 정보 섹션
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 환영 메시지
                  Text(
                    _getWelcomeMessage(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 24 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // 스트릭과 통계
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        '🔥',
                        '$_streakCount일',
                        '연속 포커스',
                        isTablet,
                      ),
                      _buildStatCard(
                        '📅',
                        '$_todaySessionCount개',
                        '오늘 세션',
                        isTablet,
                      ),
                      _buildStatCard(
                        '🎯',
                        '$_totalSessionCount개',
                        '총 세션',
                        isTablet,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 격려 메시지
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _getEncouragementMessage(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 18 : 14,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // 메인 타이머 섹션
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    Text(
                      _isFocusSession ? '포커스 시간' : '휴식 시간',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: _isFocusSession
                            ? theme.colorScheme.secondary
                            : const Color(0xFF27AE60),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 원형 타이머
                    AnimatedBuilder(
                      animation: _isRunning
                          ? _pulseAnimation
                          : const AlwaysStoppedAnimation(1.0),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isRunning ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: timerSize,
                            height: timerSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.2,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 진행상황 원
                                SizedBox(
                                  width: progressSize,
                                  height: progressSize,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 10,
                                    backgroundColor: theme.colorScheme.onSurface
                                        .withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _isFocusSession
                                          ? theme.colorScheme.secondary
                                          : const Color(0xFF27AE60),
                                    ),
                                  ),
                                ),
                                // 시간 텍스트
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatTime(_timeLeft),
                                      style: TextStyle(
                                        fontSize: timerFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    if (_isRunning)
                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _isFocusSession
                                              ? theme.colorScheme.secondary
                                                    .withOpacity(0.1)
                                              : const Color(
                                                  0xFF27AE60,
                                                ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '진행 중...',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _isFocusSession
                                                ? theme.colorScheme.secondary
                                                : const Color(0xFF27AE60),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // 컨트롤 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 시작/정지 버튼
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: GestureDetector(
                            onTapDown: (_) => _scaleController.forward(),
                            onTapUp: (_) => _scaleController.reverse(),
                            onTapCancel: () => _scaleController.reverse(),
                            onTap: _isRunning ? _stopTimer : _startTimer,
                            child: Container(
                              width: buttonSize,
                              height: buttonSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    _isRunning
                                        ? theme.colorScheme.secondary
                                        : const Color(0xFF27AE60),
                                    _isRunning
                                        ? theme.colorScheme.secondary
                                              .withOpacity(0.8)
                                        : const Color(
                                            0xFF27AE60,
                                          ).withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_isRunning
                                                ? theme.colorScheme.secondary
                                                : const Color(0xFF27AE60))
                                            .withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRunning ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: isTablet ? 45 : 35,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: isTablet ? 40 : 25),

                        // 리셋 버튼
                        GestureDetector(
                          onTap: _resetTimer,
                          child: Container(
                            width: resetButtonSize,
                            height: resetButtonSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.1,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.2,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.refresh,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                              size: isTablet ? 35 : 25,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 세션 전환 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSessionButton('포커스', _isFocusSession, () {
                          if (!_isRunning) _switchToFocusSession();
                        }, isTablet),
                        SizedBox(width: isTablet ? 25 : 15),
                        _buildSessionButton('휴식', !_isFocusSession, () {
                          if (!_isRunning) _switchToBreakSession();
                        }, isTablet),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWelcomeMessage() {
    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour < 12) {
      timeGreeting = '좋은 아침이에요! ☀️';
    } else if (hour < 18) {
      timeGreeting = '좋은 오후예요! 🌤️';
    } else {
      timeGreeting = '좋은 저녁이에요! 🌙';
    }

    if (_streakCount > 0) {
      return '$timeGreeting\n연속 $_streakCount일째 함께하고 있어요!';
    } else {
      return '$timeGreeting\n오늘도 집중해볼까요?';
    }
  }

  String _getEncouragementMessage() {
    if (_streakCount == 0) {
      return '첫 포커스 세션을 시작해보세요! 💪';
    } else if (_streakCount == 1) {
      return '훌륭해요! 좋은 시작이에요! 🎉';
    } else if (_streakCount < 7) {
      return '꾸준히 잘하고 있어요! 계속 화이팅! 🔥';
    } else if (_streakCount < 30) {
      return '정말 대단해요! 습관이 되어가고 있어요! ⭐';
    } else {
      return '놀라워요! 당신은 진정한 포커스 마스터예요! 🏆';
    }
  }

  Widget _buildStatCard(
    String emoji,
    String value,
    String label,
    bool isTablet,
  ) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: isTablet ? 32 : 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: isTablet ? 14 : 11),
        ),
      ],
    );
  }

  Widget _buildSessionButton(
    String text,
    bool isActive,
    VoidCallback onTap,
    bool isTablet,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : 24,
          vertical: isTablet ? 16 : 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.1),
          border: isActive
              ? null
              : Border.all(color: theme.colorScheme.onSurface.withOpacity(0.2)),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 18 : 14,
          ),
        ),
      ),
    );
  }
}
