import 'package:flutter/material.dart';
import '../theme/poppins.dart';
import 'package:intl/intl.dart';
import '../models/plan_item.dart';

class TimetableImage extends StatelessWidget {
  final List<PlanItem> plans;
  final DateTime weekStart;
  final String userName;

  const TimetableImage({
    super.key,
    required this.plans,
    required this.weekStart,
    required this.userName,
  });

  List<PlanItem> _forDay(DateTime day) {
    return plans.where((p) => p.occursOn(day)).map((p) => p.onDay(day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final end = weekStart.add(const Duration(days: 6));
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final shown = [for (final day in days) ..._forDay(day)];
    final exportHours = visibleHours(shown);
    const cellW = 86.0;
    const cellH = 52.0;
    const dayW = 92.0;

    return Container(
      width: dayW + exportHours.length * cellW,
      color: const Color(0xFFF7F5FF),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cədvəl',
                      style: poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D1B69),
                      ),
                    ),
                    Text(
                      '$userName · ${DateFormat('d MMM', 'az').format(weekStart)} – ${DateFormat('d MMM yyyy', 'az').format(end)}',
                      style: poppins(
                        fontSize: 13,
                        color: const Color(0xFF6B6780),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Nibras Code',
                style: poppins(
                  fontSize: 12,
                  color: const Color(0xFF6C5CE7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE6E1F5)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: dayW,
                      height: 36,
                      child: Center(
                        child: Text(
                          'Gün',
                          style: poppins(
                            fontSize: 11,
                            color: const Color(0xFF8A8499),
                          ),
                        ),
                      ),
                    ),
                    ...exportHours.map(
                      (h) => SizedBox(
                        width: cellW,
                        height: 36,
                        child: Center(
                          child: Text(
                            '${h.toString().padLeft(2, '0')}:00',
                            style: poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A4560),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ...days.map((day) {
                  final isToday = DateUtils.isSameDay(day, DateTime.now());
                  final dayPlans = _forDay(day);
                  return Container(
                    color: isToday ? const Color(0xFF6C5CE7).withOpacity(0.06) : null,
                    child: Row(
                      children: [
                        SizedBox(
                          width: dayW,
                          height: cellH,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weekdayShort(day),
                                  style: poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF8A8499),
                                  ),
                                ),
                                Text(
                                  DateFormat('d MMM', 'az').format(day),
                                  style: poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isToday
                                        ? const Color(0xFF6C5CE7)
                                        : const Color(0xFF2D1B69),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...exportHours.map((hour) {
                          final slot = DateTime(day.year, day.month, day.day, hour);
                          final next = slot.add(const Duration(hours: 1));
                          PlanItem? plan;
                          for (final p in dayPlans) {
                            if (p.startTime.isBefore(next) && p.endTime.isAfter(slot)) {
                              plan = p;
                              break;
                            }
                          }
                          final starts = plan != null &&
                              DateUtils.isSameDay(plan.startTime, day) &&
                              plan.startTime.hour == hour;
                          return Container(
                            width: cellW,
                            height: cellH,
                            decoration: BoxDecoration(
                              color: plan?.color ?? Colors.transparent,
                              border: Border(
                                left: BorderSide(
                                  color: const Color(0xFFE6E1F5),
                                ),
                                top: BorderSide(
                                  color: const Color(0xFFE6E1F5),
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: starts
                                ? Text(
                                    plan!.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.15,
                                    ),
                                  )
                                : null,
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Cədvəl · Gününə nəzarət et',
            style: poppins(
              fontSize: 11,
              color: const Color(0xFF8A8499),
            ),
          ),
        ],
      ),
    );
  }
}
