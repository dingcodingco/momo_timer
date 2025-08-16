import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';

class StorageService {
  static const String _sessionsKey = 'sessions';

  static Future<List<Session>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList(_sessionsKey) ?? [];

    return sessionsJson
        .map((json) => Session.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime)); // 최신 순으로 정렬
  }

  static Future<void> saveSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getSessions();
    sessions.insert(0, session); // 최신 세션을 맨 앞에 추가

    final sessionsJson = sessions
        .map((session) => jsonEncode(session.toJson()))
        .toList();

    await prefs.setStringList(_sessionsKey, sessionsJson);
  }
}
