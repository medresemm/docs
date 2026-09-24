import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plan_item.dart';
import 'reminder_service.dart';

class PlanService extends ChangeNotifier {
  static const int freePlanLimit = 7;

  List<PlanItem> _plans = [];
  bool _isPremium = false;
  String _userName = '';
  String _locale = 'az';
  ThemeMode _themeMode = ThemeMode.system;
  List<String> _categories = ['Dərs', 'Tapşırıq', 'Tədbir', 'Şəxsi'];
  bool _onboardingDone = false;
  bool _loaded = false;
  /// 1 = Bazar ertəsi … 7 = Bazar (DateTime.weekday)
  int _weekStartsOn = 1;
  bool _remindersEnabled = true;
  bool _soundEnabled = true;
  Timer? _reminderTimer;
  final Set<String> _firedReminders = {};

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  List<PlanItem> get plans => List.unmodifiable(_plans);
  bool get isPremium => _isPremium;
  String get userName => _userName;
  String get locale => _locale;
  bool get english => _locale == 'en';
  ThemeMode get themeMode => _themeMode;
  List<String> get categories => List.unmodifiable(_categories);
  bool get onboardingDone => _onboardingDone;
  bool get isLoaded => _loaded;
  int get weekStartsOn => _weekStartsOn;
  bool get remindersEnabled => _remindersEnabled;
  bool get soundEnabled => _soundEnabled;

  bool get canAddPlan => _isPremium || _plans.length < freePlanLimit;

  int get remainingFreeSlots {
    if (_isPremium) return 999;
    return (freePlanLimit - _plans.length).clamp(0, freePlanLimit);
  }

  DateTime weekStart([DateTime? date]) {
    final now = date ?? DateTime.now();
    final d = DateTime(now.year, now.month, now.day);
    final diff = (d.weekday - _weekStartsOn + 7) % 7;
    return d.subtract(Duration(days: diff));
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('plans');
    _isPremium = prefs.getBool('isPremium') ?? false;
    _userName = prefs.getString('userName') ?? '';
    if (_userName == 'Həkim') _userName = '';
    _locale = prefs.getString('locale') == 'en' ? 'en' : 'az';
    ReminderService.instance.english = _locale == 'en';
    _onboardingDone = prefs.getBool('onboardingDone') ?? false;
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex.clamp(0, 2)];
    final cats = prefs.getStringList('categories');
    if (cats != null && cats.isNotEmpty) _categories = cats;
    _weekStartsOn = (prefs.getInt('weekStartsOn') ?? 1).clamp(1, 7);
    _remindersEnabled = prefs.getBool('remindersEnabled') ?? true;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;

    if (data != null) {
      final list = jsonDecode(data) as List;
      _plans = list.map((e) => PlanItem.fromJson(e)).toList();
    } else {
      _plans = [];
    }
    _loaded = true;
    notifyListeners();
    await ReminderService.instance.resync(_plans, enabled: _remindersEnabled);
    _startReminderTicker();
  }

  void _startReminderTicker() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkDueReminders(),
    );
    _checkDueReminders();
  }

  void _checkDueReminders() {
    if (!_remindersEnabled) return;
    final now = DateTime.now();
    for (final p in _plans) {
      if (p.reminderOffsetMin == null) continue;
      final start = p.repeatWeekly
          ? p.nextStart(now.subtract(const Duration(hours: 3)))
          : p.startTime;
      final when = start.subtract(Duration(minutes: p.reminderOffsetMin!));
      if (now.isBefore(when.subtract(const Duration(seconds: 8)))) continue;
      if (now.isAfter(when.add(const Duration(minutes: 2)))) continue;
      final key = '${p.id}-${when.millisecondsSinceEpoch}';
      if (_firedReminders.contains(key)) continue;
      _firedReminders.add(key);
      final en = ReminderService.instance.english;
      final body = p.reminderOffsetMin == 0
          ? (en ? 'starts now' : 'indi başlayır')
          : en
              ? 'starts in ${p.reminderOffsetMin} min'
              : '${p.reminderOffsetMin} dəqiqə sonra başlayır';
      ReminderService.instance.showBanner(
        ReminderEvent(
          id: key,
          planId: p.id,
          title: p.title,
          body: '$body${p.location != null ? ' · ${p.location}' : ''}',
        ),
        sound: _soundEnabled,
      );
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'plans',
      jsonEncode(_plans.map((e) => e.toJson()).toList()),
    );
    await prefs.setBool('isPremium', _isPremium);
    await prefs.setString('userName', _userName);
    await prefs.setString('locale', _locale);
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setStringList('categories', _categories);
    await prefs.setBool('onboardingDone', _onboardingDone);
    await prefs.setInt('weekStartsOn', _weekStartsOn);
    await prefs.setBool('remindersEnabled', _remindersEnabled);
    await prefs.setBool('soundEnabled', _soundEnabled);
  }

  void completeOnboarding() {
    _onboardingDone = true;
    save();
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name.trim();
    save();
    notifyListeners();
  }

  void setLocale(String code) {
    _locale = code == 'en' ? 'en' : 'az';
    ReminderService.instance.english = _locale == 'en';
    save();
    notifyListeners();
    ReminderService.instance.resync(_plans, enabled: _remindersEnabled);
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    save();
    notifyListeners();
  }

  void setWeekStartsOn(int day) {
    _weekStartsOn = day.clamp(1, 7);
    save();
    notifyListeners();
  }

  Future<void> setRemindersEnabled(bool value) async {
    _remindersEnabled = value;
    if (value) await ReminderService.instance.requestPermission();
    await save();
    notifyListeners();
    await ReminderService.instance.resync(_plans, enabled: value);
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    save();
    notifyListeners();
  }

  void addCategory(String name) {
    if (name.trim().isEmpty || _categories.contains(name.trim())) return;
    if (!_isPremium && _categories.length >= 4) return;
    _categories.add(name.trim());
    save();
    notifyListeners();
  }

  void removeCategory(String name) {
    _categories.remove(name);
    save();
    notifyListeners();
  }

  bool addPlan(PlanItem item) {
    if (!canAddPlan) return false;
    _plans.add(item);
    save();
    notifyListeners();
    ReminderService.instance.schedule(item, enabled: _remindersEnabled);
    return true;
  }

  void updatePlan(PlanItem item) {
    final index = _plans.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _plans[index] = item;
      save();
      notifyListeners();
      ReminderService.instance.schedule(item, enabled: _remindersEnabled);
    }
  }

  void deletePlan(String id) {
    _plans.removeWhere((e) => e.id == id);
    save();
    notifyListeners();
    ReminderService.instance.cancel(id);
  }

  void toggleComplete(String id) {
    final index = _plans.indexWhere((e) => e.id == id);
    if (index != -1) {
      _plans[index].isCompleted = !_plans[index].isCompleted;
      save();
      notifyListeners();
    }
  }

  void setPremium(bool value) {
    _isPremium = value;
    save();
    notifyListeners();
  }

  void clearAllPlans() {
    _plans.clear();
    save();
    notifyListeners();
    ReminderService.instance.cancelAll();
  }

  List<PlanItem> getPlansForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _plans.where((p) => p.occursOn(d)).map((p) => p.onDay(d)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<PlanItem> getPlansForWeek(DateTime ws) {
    final start = DateTime(ws.year, ws.month, ws.day);
    final items = <PlanItem>[];
    for (var i = 0; i < 7; i++) {
      items.addAll(getPlansForDay(start.add(Duration(days: i))));
    }
    return items;
  }

  List<PlanItem> search(String query) {
    if (query.trim().isEmpty) return plans;
    final q = query.toLowerCase();
    return _plans.where((p) {
      return p.title.toLowerCase().contains(q) ||
          (p.subtitle?.toLowerCase().contains(q) ?? false) ||
          (p.location?.toLowerCase().contains(q) ?? false) ||
          (p.note?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  double getCompletionRate() {
    if (_plans.isEmpty) return 0;
    return _plans.where((p) => p.isCompleted).length / _plans.length;
  }

  double typeRate(PlanType type) {
    final items = _plans.where((p) => p.type == type).toList();
    if (items.isEmpty) return 0;
    return items.where((p) => p.isCompleted).length / items.length;
  }
}
