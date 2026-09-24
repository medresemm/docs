import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/poppins.dart';
import '../services/plan_service.dart';
import '../models/plan_item.dart';
import '../widgets/plan_card.dart';
import '../services/timetable_export.dart';
import '../l10n/tr.dart';

class WeeklyScreen extends StatefulWidget {
  const WeeklyScreen({super.key});

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  late DateTime _anchor;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _anchor = DateTime.now();
  }

  void _changeWeek(int delta) {
    setState(() {
      _anchor = _anchor.add(Duration(days: 7 * delta));
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PlanService>();
    final en = service.english;
    final loc = en ? 'en' : 'az';
    final weekStart = service.weekStart(_anchor);
    final plans = service.getPlansForWeek(weekStart);
    final end = weekStart.add(const Duration(days: 6));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr(context, 'Həftəlik plan', 'Weekly plan'),
                    style: poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Şəkil kimi yüklə',
                        onPressed: () => TimetableExport.showSheet(
                          context,
                          plans: service.plans,
                          weekStart: weekStart,
                          userName: service.userName,
                        ),
                        icon: const Icon(Icons.download_rounded),
                      ),
                      IconButton(
                        onPressed: () => _changeWeek(-1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        onPressed: () => _changeWeek(1),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${DateFormat('d MMM', loc).format(weekStart)} – ${DateFormat('d MMM yyyy', loc).format(end)}',
                style: poppins(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),

            // Days strip
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 7,
                itemBuilder: (context, i) {
                  final day = weekStart.add(Duration(days: i));
                  final isToday = DateUtils.isSameDay(day, DateTime.now());
                  final isSel = _selected != null &&
                      DateUtils.isSameDay(day, _selected);
                  final dayPlans = service.getPlansForDay(day);

                  return GestureDetector(
                    onTap: () => setState(() => _selected = day),
                    child: Container(
                    width: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSel
                          ? const Color(0xFF6C5CE7)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel || isToday
                            ? const Color(0xFF6C5CE7)
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdayShort(day, en: en),
                          style: poppins(
                            fontSize: 12,
                            color: isSel ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        Text(
                          '${day.day}',
                          style: poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : null,
                          ),
                        ),
                        if (dayPlans.isNotEmpty)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSel ? Colors.white : const Color(0xFF6C5CE7),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Builder(
                builder: (context) {
                  final shown = _selected == null
                      ? plans
                      : service.getPlansForDay(_selected!);
                  if (shown.isEmpty) {
                    return Center(
                      child: Text(
                        _selected == null
                            ? tr(context, 'Bu həftə plan yoxdur', 'No plans this week')
                            : tr(context, 'Bu gün plan yoxdur', 'No plans this day'),
                        style: poppins(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: shown.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PlanCard(plan: shown[index], showDate: true),
                        );
                      },
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
