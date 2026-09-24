import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/poppins.dart';
import 'package:intl/intl.dart';
import '../models/plan_item.dart';
import '../services/plan_service.dart';
import '../l10n/tr.dart';
import 'add_plan_screen.dart';

class PlanDetailScreen extends StatelessWidget {
  final String planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PlanService>();
    PlanItem? plan;
    for (final p in service.plans) {
      if (p.id == planId) {
        plan = p;
        break;
      }
    }
    if (plan == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final current = plan;
    final en = service.english;
    final loc = en ? 'en' : 'az';
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('d MMMM yyyy, EEEE', loc);
    String typeName(PlanType type) {
      switch (type) {
        case PlanType.lesson:
          return tr(context, 'Dərs', 'Lesson');
        case PlanType.task:
          return tr(context, 'Tapşırıq', 'Task');
        case PlanType.event:
          return tr(context, 'Tədbir', 'Event');
        case PlanType.note:
          return tr(context, 'Qeyd', 'Note');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Dərs təfərrüatı', 'Plan details'), style: poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddPlanScreen(plan: current),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: plan.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: plan.color.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: plan.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        typeName(plan.type),
                        style: poppins(
                          color: plan.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    plan.title,
                    style: poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (plan.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      plan.subtitle!,
                      style: poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            _infoTile(Icons.calendar_today, tr(context, 'Tarix', 'Date'), dateFormat.format(plan.startTime)),
            if (plan.repeatWeekly)
              _infoTile(
                Icons.repeat,
                tr(context, 'Təkrar', 'Repeat'),
                '${tr(context, 'Hər həftə', 'Every week')} · ${weekdayLong(plan.startTime.weekday, en: en)}',
              ),
            _infoTile(
              Icons.access_time,
              tr(context, 'Vaxt', 'Time'),
              '${timeFormat.format(plan.startTime)} – ${timeFormat.format(plan.endTime)}',
            ),
            if (plan.location != null)
              _infoTile(Icons.location_on_outlined, tr(context, 'Məkan', 'Place'), plan.location!),
            if (plan.note != null && plan.note!.isNotEmpty)
              _infoTile(Icons.notes, tr(context, 'Qeyd', 'Note'), plan.note!),
            _infoTile(
              Icons.category_outlined,
              tr(context, 'Kateqoriya', 'Category'),
              plan.category,
            ),
            _infoTile(
              Icons.notifications_outlined,
              tr(context, 'Xəbərdarlıq', 'Reminder'),
              reminderLabel(plan.reminderOffsetMin, en: en),
            ),

            const SizedBox(height: 12),
            _infoTile(
              plan.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              tr(context, 'Status', 'Status'),
              plan.isCompleted ? tr(context, 'Tamamlanıb', 'Done') : tr(context, 'Gözləyir', 'Pending'),
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final messenger = ScaffoldMessenger.of(context);
                      context.read<PlanService>().deletePlan(current.id);
                      Navigator.pop(context);
                      messenger.showSnackBar(
                        SnackBar(content: Text(trRead(context, 'Plan silindi', 'Plan deleted'))),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: Text(tr(context, 'Sil', 'Delete'), style: poppins(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<PlanService>().toggleComplete(current.id);
                      Navigator.pop(context);
                    },
                    icon: Icon(plan.isCompleted ? Icons.undo : Icons.check),
                    label: Text(
                      plan.isCompleted ? tr(context, 'Geri al', 'Undo') : tr(context, 'Tamamla', 'Complete'),
                      style: poppins(),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.grey[600]),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: poppins(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: poppins(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
