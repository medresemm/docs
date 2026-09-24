import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum PlanType { lesson, task, event, note }

class PlanItem {
  final String id;
  String title;
  String? subtitle;
  String? location;
  DateTime startTime;
  DateTime endTime;
  PlanType type;
  String category;
  Color color;
  bool isCompleted;
  String? note;
  /// Minutes before start. null = no reminder. 0 = at start.
  int? reminderOffsetMin;
  /// Same weekday and clock time, every week from [startTime] onward.
  bool repeatWeekly;

  PlanItem({
    String? id,
    required this.title,
    this.subtitle,
    this.location,
    required this.startTime,
    required this.endTime,
    this.type = PlanType.lesson,
    this.category = 'Dərs',
    this.color = const Color(0xFF6C5CE7),
    this.isCompleted = false,
    this.note,
    this.reminderOffsetMin = 10,
    this.repeatWeekly = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'location': location,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'type': type.index,
        'category': category,
        'color': color.value, // ignore: deprecated_member_use
        'isCompleted': isCompleted,
        'note': note,
        'reminderOffsetMin': reminderOffsetMin,
        'repeatWeekly': repeatWeekly,
      };

  factory PlanItem.fromJson(Map<String, dynamic> json) => PlanItem(
        id: json['id'],
        title: json['title'],
        subtitle: json['subtitle'],
        location: json['location'],
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        type: PlanType.values[json['type'] ?? 0],
        category: json['category'] ?? 'Dərs',
        color: Color(json['color'] ?? 0xFF6C5CE7),
        isCompleted: json['isCompleted'] ?? false,
        note: json['note'],
        reminderOffsetMin: json['reminderOffsetMin'],
        repeatWeekly: json['repeatWeekly'] == true,
      );

  PlanItem copyWith({
    String? title,
    String? subtitle,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    PlanType? type,
    String? category,
    Color? color,
    bool? isCompleted,
    String? note,
    int? reminderOffsetMin,
    bool? repeatWeekly,
    bool clearReminder = false,
  }) {
    return PlanItem(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      category: category ?? this.category,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      note: note ?? this.note,
      reminderOffsetMin:
          clearReminder ? null : (reminderOffsetMin ?? this.reminderOffsetMin),
      repeatWeekly: repeatWeekly ?? this.repeatWeekly,
    );
  }

  Duration get duration {
    final d = endTime.difference(startTime);
    return d.isNegative || d == Duration.zero ? const Duration(hours: 1) : d;
  }

  bool occursOn(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final origin = DateTime(startTime.year, startTime.month, startTime.day);
    if (!repeatWeekly) return d == origin;
    if (d.isBefore(origin)) return false;
    return d.weekday == startTime.weekday;
  }

  /// Next clock start at or after [from].
  DateTime nextStart(DateTime from) {
    if (!repeatWeekly) return startTime;
    final origin = DateTime(startTime.year, startTime.month, startTime.day);
    var day = DateTime(from.year, from.month, from.day);
    if (day.isBefore(origin)) day = origin;
    final delta = (startTime.weekday - day.weekday + 7) % 7;
    day = day.add(Duration(days: delta));
    var when = DateTime(
      day.year,
      day.month,
      day.day,
      startTime.hour,
      startTime.minute,
    );
    if (when.isBefore(from)) when = when.add(const Duration(days: 7));
    if (when.isBefore(startTime)) return startTime;
    return when;
  }

  PlanItem onDay(DateTime day) {
    if (!repeatWeekly) return this;
    final start = DateTime(
      day.year,
      day.month,
      day.day,
      startTime.hour,
      startTime.minute,
    );
    return copyWith(startTime: start, endTime: start.add(duration));
  }
}

const reminderOffsets = <int, String>{
  -1: 'Xəbərdarlıq yoxdur',
  0: 'Dərs başlayanda',
  5: '5 dəqiqə əvvəl',
  10: '10 dəqiqə əvvəl',
  15: '15 dəqiqə əvvəl',
  30: '30 dəqiqə əvvəl',
  60: '1 saat əvvəl',
};

String reminderLabel(int? minutes, {bool en = false}) {
  final map = reminderChoices(en: en);
  if (minutes == null) return map[-1]!;
  return map[minutes] ?? map[-1]!;
}

Map<int, String> reminderChoices({required bool en}) {
  if (!en) return reminderOffsets;
  return const {
    -1: 'No reminder',
    0: 'When it starts',
    5: '5 minutes before',
    10: '10 minutes before',
    15: '15 minutes before',
    30: '30 minutes before',
    60: '1 hour before',
  };
}

String weekdayShort(DateTime day, {bool en = false}) {
  const az = {
    1: 'B.e',
    2: 'Ç.a',
    3: 'Çər',
    4: 'C.a',
    5: 'Cüm',
    6: 'Şən',
    7: 'Baz',
  };
  const enL = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };
  return (en ? enL : az)[day.weekday] ?? '';
}

String weekdayLong(int weekday, {bool en = false}) {
  const az = {
    1: 'Bazar ertəsi',
    2: 'Çərşənbə axşamı',
    3: 'Çərşənbə',
    4: 'Cümə axşamı',
    5: 'Cümə',
    6: 'Şənbə',
    7: 'Bazar',
  };
  const enL = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };
  return (en ? enL : az)[weekday] ?? '';
}

/// Grid hours. Defaults to 08–19 and grows to fit earlier or later plans.
List<int> visibleHours(Iterable<PlanItem> plans) {
  var minH = 8;
  var maxH = 19;
  for (final p in plans) {
    if (p.startTime.hour < minH) minH = p.startTime.hour;
    var endH = p.endTime.hour;
    if (p.endTime.minute == 0 && p.endTime.isAfter(p.startTime)) {
      endH -= 1;
    }
    if (endH > maxH) maxH = endH;
    if (p.startTime.hour > maxH) maxH = p.startTime.hour;
  }
  if (minH < 0) minH = 0;
  if (maxH > 23) maxH = 23;
  if (maxH < minH) maxH = minH;
  return [for (var h = minH; h <= maxH; h++) h];
}
