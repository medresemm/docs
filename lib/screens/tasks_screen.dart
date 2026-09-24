import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/poppins.dart';
import '../services/plan_service.dart';
import '../models/plan_item.dart';
import '../widgets/plan_card.dart';
import '../l10n/tr.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PlanService>();
    final tasks = service.plans
        .where((p) => p.type == PlanType.task)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final pending = tasks.where((t) => !t.isCompleted).toList();
    final done = tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                tr(context, 'Tapşırıqlar', 'Tasks'),
                style: poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _countChip(tr(context, 'Gözləyən', 'Pending'), pending.length, const Color(0xFFE17055)),
                  const SizedBox(width: 10),
                  _countChip(tr(context, 'Tamamlanan', 'Done'), done.length, const Color(0xFF00B894)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            tr(context, 'Tapşırıq yoxdur', 'No tasks'),
                            style: poppins(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (pending.isNotEmpty) ...[
                          Text(
                            tr(context, 'Gözləyən', 'Pending'),
                            style: poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...pending.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: PlanCard(plan: p),
                              )),
                          const SizedBox(height: 16),
                        ],
                        if (done.isNotEmpty) ...[
                          Text(
                            tr(context, 'Tamamlanan', 'Done'),
                            style: poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...done.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: PlanCard(plan: p),
                              )),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            '$count',
            style: poppins(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: poppins(fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }
}
