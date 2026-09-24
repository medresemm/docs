import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/plan_item.dart';

class ReminderEvent {
  final String id;
  final String? planId;
  final String title;
  final String body;
  ReminderEvent({
    required this.id,
    this.planId,
    required this.title,
    required this.body,
  });
}

class ReminderService extends ChangeNotifier {
  ReminderService._();
  static final instance = ReminderService._();

  static const horizonWeeks = 8;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _initializing = false;
  bool english = false;
  ReminderEvent? banner;
  String? _pendingPlanId;
  void Function(String planId)? onOpenPlan;

  Future<void> init() async {
    if (_ready || _initializing) return;
    _initializing = true;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Baku'));
    } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (resp) {
        final id = resp.payload;
        if (id != null && id.isNotEmpty) _open(id);
      },
    );
    await _askPermissions();
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if ((launch?.didNotificationLaunchApp ?? false) &&
        payload != null &&
        payload.isNotEmpty) {
      _pendingPlanId = payload;
    }
    _ready = true;
    _initializing = false;
  }

  void bindNavigator(void Function(String planId) open) {
    onOpenPlan = open;
    final pending = _pendingPlanId;
    if (pending != null) {
      _pendingPlanId = null;
      open(pending);
    }
  }

  void _open(String planId) {
    if (onOpenPlan != null) {
      onOpenPlan!(planId);
    } else {
      _pendingPlanId = planId;
    }
  }

  Future<void> requestPermission() async {
    if (!_ready) {
      await init();
      return;
    }
    await _askPermissions();
  }

  Future<void> _askPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    try {
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('exact alarm permission: $e');
    }
  }

  int _nid(String planId, int index) =>
      (Object.hash(planId, index) & 0x7fffffff);

  NotificationDetails _details() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'cedvel_ders',
        english ? 'Lesson reminder' : 'Dərs xəbərdarlığı',
        channelDescription: english
            ? 'Lesson and plan reminders'
            : 'Dərs və plan xəbərdarlıqları',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  String _body(PlanItem plan) {
    final where = plan.location != null ? ' · ${plan.location}' : '';
    if (plan.reminderOffsetMin == 0) {
      return (english ? 'starts now' : 'indi başlayır') + where;
    }
    return english
        ? 'starts in ${plan.reminderOffsetMin} min$where'
        : '${plan.reminderOffsetMin} dəqiqə sonra başlayır$where';
  }

  Future<void> _scheduleAt({
    required int id,
    required PlanItem plan,
    required DateTime when,
  }) async {
    if (when.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
      return;
    }
    final details = _details();
    final tzWhen = tz.TZDateTime.from(when, tz.local);
    try {
      await _plugin.zonedSchedule(
        id,
        plan.title,
        _body(plan),
        tzWhen,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: plan.id,
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          id,
          plan.title,
          _body(plan),
          tzWhen,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: plan.id,
        );
      } catch (e) {
        debugPrint('reminder schedule failed: $e');
      }
    }
  }

  Future<void> schedule(PlanItem plan, {required bool enabled}) async {
    await init();
    await cancel(plan.id);
    if (!enabled || plan.reminderOffsetMin == null) return;
    final starts = <DateTime>[];
    if (!plan.repeatWeekly) {
      starts.add(plan.startTime);
    } else {
      var cursor = DateTime.now().subtract(const Duration(minutes: 1));
      for (var i = 0; i < horizonWeeks; i++) {
        final next = plan.nextStart(cursor);
        starts.add(next);
        cursor = next.add(const Duration(minutes: 1));
      }
    }
    for (var i = 0; i < starts.length; i++) {
      final when =
          starts[i].subtract(Duration(minutes: plan.reminderOffsetMin!));
      await _scheduleAt(id: _nid(plan.id, i), plan: plan, when: when);
    }
  }

  Future<void> cancel(String planId) async {
    await init();
    for (var i = 0; i < horizonWeeks; i++) {
      await _plugin.cancel(_nid(planId, i));
    }
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  Future<void> resync(List<PlanItem> plans, {required bool enabled}) async {
    await cancelAll();
    if (!enabled) return;
    for (final p in plans) {
      await schedule(p, enabled: true);
    }
  }

  void fireTest({required bool sound}) {
    showBanner(
      ReminderEvent(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        title: english ? 'Math lesson' : 'Riyaziyyat dərsi',
        body: english
            ? 'starts in 10 min · Room 301'
            : '10 dəqiqə sonra başlayır · Sinif 301',
      ),
      sound: sound,
    );
  }

  void showBanner(ReminderEvent event, {required bool sound}) {
    banner = event;
    notifyListeners();
    if (sound) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  void dismissBanner() {
    banner = null;
    notifyListeners();
  }
}
