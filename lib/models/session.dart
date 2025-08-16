class Session {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String type; // 'focus' or 'break'
  final String mood; // 이모지

  Session({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.mood,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'type': type,
      'mood': mood,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime']),
      type: json['type'],
      mood: json['mood'],
    );
  }

  int get duration => endTime.difference(startTime).inMinutes;
}
