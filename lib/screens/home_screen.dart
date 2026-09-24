import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/poppins.dart';
import '../services/plan_service.dart';
import '../models/plan_item.dart';
import 'add_plan_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'premium_screen.dart';
import 'plan_detail_screen.dart';
import '../services/timetable_export.dart';
import '../l10n/tr.dart';

const _weekDays = [
  (1, 'B.e.', 'Bazar ertəsi'),
  (2, 'Ç.a.', 'Çərşənbə axşamı'),
  (3, 'Çər.', 'Çərşənbə'),
  (4, 'C.a.', 'Cümə axşamı'),
  (5, 'Cüm.', 'Cümə'),
  (6, 'Şən.', 'Şənbə'),
  (7, 'Baz.', 'Bazar'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _anchor;
  DateTime? _selDay;
  int? _selStart;
  int? _selEnd;

  @override
  void initState() {
    super.initState();
    _anchor = DateTime.now();
  }

  DateTime _slot(DateTime day, int hour) =>
      DateTime(day.year, day.month, day.day, hour);

  void _tapCell(DateTime day, int hour, PlanItem? occupied) {
    if (occupied != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlanDetailScreen(planId: occupied.id),
        ),
      );
      return;
    }
    setState(() {
      if (_selDay != null &&
          DateUtils.isSameDay(_selDay, day) &&
          _selStart != null &&
          _selEnd != null) {
        if (hour >= _selStart! && hour < _selEnd! && _selEnd! - _selStart! == 1) {
          _selDay = null;
          _selStart = null;
          _selEnd = null;
          return;
        }
        final lo = hour < _selStart! ? hour : _selStart!;
        final hi = hour >= _selEnd! ? hour + 1 : _selEnd!;
        _selDay = day;
        _selStart = lo;
        _selEnd = hi;
      } else {
        _selDay = day;
        _selStart = hour;
        _selEnd = hour + 1;
      }
    });
  }

  void _addFromSelection(PlanService service) {
    if (!service.canAddPlan) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );
      return;
    }
    DateTime start;
    DateTime end;
    if (_selDay != null && _selStart != null && _selEnd != null) {
      start = _slot(_selDay!, _selStart!);
      end = _slot(_selDay!, _selEnd!);
    } else {
      start = DateTime.now().add(const Duration(hours: 1));
      start = DateTime(start.year, start.month, start.day, start.hour);
      end = start.add(const Duration(hours: 1));
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPlanScreen(initialStart: start, initialEnd: end),
      ),
    ).then((_) => setState(() {
          _selDay = null;
          _selStart = null;
          _selEnd = null;
        }));
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PlanService>();
    final en = service.english;
    final ws = service.weekStart(_anchor);
    final end = ws.add(const Duration(days: 6));
    final days = List.generate(7, (i) => ws.add(Duration(days: i)));
    final hours = visibleHours(service.getPlansForWeek(ws));
    final hello = service.userName.isEmpty
        ? tr(context, 'Salam', 'Hello')
        : tr(context, 'Salam, ${service.userName}', 'Hello, ${service.userName}');

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hello,
                          style: poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Cədvəl',
                          style: poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Şəkil kimi yüklə',
                    onPressed: () => TimetableExport.showSheet(
                      context,
                      plans: service.plans,
                      weekStart: ws,
                      userName: service.userName,
                    ),
                    icon: const Icon(Icons.download_rounded),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
            if (!service.isPremium)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                  ),
                  tileColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  title: Text(
                    tr(context, 'Premium: limitsiz plan', 'Premium: unlimited plans'),
                    style: poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    tr(
                      context,
                      '${service.remainingFreeSlots} pulsuz yer qalıb',
                      '${service.remainingFreeSlots} free slots left',
                    ),
                    style: poppins(fontSize: 12),
                  ),
                  trailing: Text(
                    tr(context, 'Aç', 'Open'),
                    style: poppins(
                      color: const Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                tr(context, 'Həftənin başlanğıcı', 'Week starts on'),
                style: poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _weekDays.map((d) {
                  final selected = service.weekStartsOn == d.$1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        en
                            ? weekdayShort(DateTime(2024, 1, d.$1), en: true)
                            : d.$2,
                      ),
                      selected: selected,
                      onSelected: (_) {
                        service.setWeekStartsOn(d.$1);
                        setState(() {
                          _selDay = null;
                          _selStart = null;
                          _selEnd = null;
                        });
                      },
                      selectedColor: const Color(0xFF6C5CE7),
                      labelStyle: poppins(
                        color: selected ? Colors.white : null,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
              child: Row(
                children: [
                  Text(
                    '${DateFormat('d MMM', en ? 'en' : 'az').format(ws)} – ${DateFormat('d MMM', en ? 'en' : 'az').format(end)}',
                    style: poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(() {
                      _anchor = ws.subtract(const Duration(days: 7));
                      _selDay = null;
                    }),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _anchor = ws.add(const Duration(days: 7));
                      _selDay = null;
                    }),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(
                tr(
                  context,
                  'Saatlar yuxarıda, günlər solda. Boş xananı seçin.',
                  'Hours on top, days on the left. Tap an empty cell.',
                ),
                style: poppins(fontSize: 11, color: Colors.grey),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 72 + hours.length * 56,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 72,
                            child: Text(
                              tr(context, 'Gün', 'Day'),
                              textAlign: TextAlign.center,
                              style: poppins(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          ...hours.map(
                            (h) => SizedBox(
                              width: 56,
                              child: Text(
                                '${h.toString().padLeft(2, '0')}:00',
                                textAlign: TextAlign.center,
                                style: poppins(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 7,
                          itemBuilder: (context, di) {
                            final day = days[di];
                            final isToday =
                                DateUtils.isSameDay(day, DateTime.now());
                            return Container(
                              color: isToday
                                  ? const Color(0xFF6C5CE7).withOpacity(0.06)
                                  : null,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 72,
                                    height: 44,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          weekdayShort(day, en: en),
                                          style: poppins(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '${day.day}',
                                          style: poppins(
                                            fontWeight: FontWeight.w600,
                                            color: isToday
                                                ? const Color(0xFF6C5CE7)
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...hours.map((hour) {
                                    final occupying = service
                                        .getPlansForDay(day)
                                        .where((p) {
                                      final s = DateTime(day.year, day.month,
                                              day.day, hour);
                                      final e = s.add(const Duration(hours: 1));
                                      return p.startTime.isBefore(e) &&
                                          p.endTime.isAfter(s);
                                    }).toList();
                                    final plan =
                                        occupying.isEmpty ? null : occupying.first;
                                    final selected = _selDay != null &&
                                        DateUtils.isSameDay(_selDay, day) &&
                                        _selStart != null &&
                                        _selEnd != null &&
                                        hour >= _selStart! &&
                                        hour < _selEnd!;
                                    final startsHere = plan != null &&
                                        plan.startTime.hour == hour &&
                                        DateUtils.isSameDay(
                                            plan.startTime, day);
                                    return GestureDetector(
                                      onTap: () =>
                                          _tapCell(day, hour, plan),
                                      child: Container(
                                        width: 56,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: plan != null
                                              ? plan.color
                                              : selected
                                                  ? const Color(0xFF6C5CE7)
                                                      .withOpacity(0.18)
                                                  : Colors.transparent,
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.grey.withOpacity(0.2),
                                            ),
                                            bottom: BorderSide(
                                              color: Colors.grey.withOpacity(0.2),
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: startsHere
                                            ? Text(
                                                plan.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: poppins(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_selDay != null && _selStart != null && _selEnd != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${DateFormat('d MMM', 'az').format(_selDay!)} · ${_selStart!.toString().padLeft(2, '0')}:00–${_selEnd!.toString().padLeft(2, '0')}:00',
                        style: poppins(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _selDay = null;
                        _selStart = null;
                        _selEnd = null;
                      }),
                      child: Text(tr(context, 'Ləğv', 'Cancel')),
                    ),
                    ElevatedButton(
                      onPressed: () => _addFromSelection(service),
                      child: Text(tr(context, 'Plan əlavə et', 'Add plan')),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
