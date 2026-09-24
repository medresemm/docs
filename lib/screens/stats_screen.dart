import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/poppins.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/plan_item.dart';
import '../services/plan_service.dart';
import '../l10n/tr.dart';
import 'premium_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PlanService>();
    final total = service.plans.length;
    final completed = service.plans.where((p) => p.isCompleted).length;
    final rate = service.getCompletionRate();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'Statistikalar', 'Statistics'),
                style: poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Big progress circle
              Center(
                child: CircularPercentIndicator(
                  radius: 90,
                  lineWidth: 14,
                  percent: rate.clamp(0.0, 1.0),
                  animation: true,
                  animationDuration: 800,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(rate * 100).toStringAsFixed(0)}%',
                        style: poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6C5CE7),
                        ),
                      ),
                      Text(
                        tr(context, 'Tamamlanma', 'Completion'),
                        style: poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  progressColor: const Color(0xFF6C5CE7),
                  backgroundColor: const Color(0xFF6C5CE7).withOpacity(0.15),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ),
              const SizedBox(height: 32),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context,
                      tr(context, 'Ümumi plan', 'All plans'),
                      '$total',
                      Icons.event_note,
                      const Color(0xFF6C5CE7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      context,
                      tr(context, 'Tamamlanan', 'Done'),
                      '$completed',
                      Icons.check_circle,
                      const Color(0xFF00B894),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context,
                      tr(context, 'Gözləyən', 'Pending'),
                      '${total - completed}',
                      Icons.pending_actions,
                      const Color(0xFFE17055),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      context,
                      tr(context, 'Bu həftə', 'This week'),
                      '${service.getPlansForWeek(service.weekStart()).length}',
                      Icons.view_week,
                      const Color(0xFF00CEC9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                tr(context, 'İrəliləyiş', 'Progress'),
                style: poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _progressRow(tr(context, 'Dərslər', 'Lessons'), service.typeRate(PlanType.lesson), const Color(0xFF6C5CE7)),
                    const SizedBox(height: 12),
                    _progressRow(tr(context, 'Tapşırıqlar', 'Tasks'), service.typeRate(PlanType.task), const Color(0xFFFDCB6E)),
                    const SizedBox(height: 12),
                    _progressRow(tr(context, 'Tədbirlər', 'Events'), service.typeRate(PlanType.event), const Color(0xFF00B894)),
                    const SizedBox(height: 12),
                    _progressRow(tr(context, 'Qeydlər', 'Notes'), service.typeRate(PlanType.note), const Color(0xFFFD79A8)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (service.isPremium)
                _advanced(context, service)
              else
                _premiumLock(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumLock(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(Icons.lock_outline, color: Color(0xFF6C5CE7)),
        title: Text(
          tr(context, 'Təkmil statistika', 'Advanced statistics'),
          style: poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          tr(context, 'Kateqoriya və son 4 həftə Premium-dadır', 'Categories and the last 4 weeks are in Premium'),
          style: poppins(fontSize: 12),
        ),
        trailing: Text(
          tr(context, 'Aç', 'Open'),
          style: poppins(color: const Color(0xFF6C5CE7), fontWeight: FontWeight.w600),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PremiumScreen()),
        ),
      ),
    );
  }

  Widget _advanced(BuildContext context, PlanService service) {
    final byCat = <String, List<PlanItem>>{};
    for (final p in service.plans) {
      byCat.putIfAbsent(p.category, () => []).add(p);
    }
    final weeks = List.generate(4, (i) {
      final start = service.weekStart(DateTime.now().subtract(Duration(days: 7 * (3 - i))));
      final items = service.getPlansForWeek(start);
      final done = items.where((p) => p.isCompleted).length;
      return (start, items.length, done);
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'Kateqoriyalar', 'Categories'),
          style: poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              if (byCat.isEmpty)
                Text(tr(context, 'Hələ plan yoxdur', 'No plans yet'), style: poppins(color: Colors.grey))
              else
                for (final entry in byCat.entries) ...[
                  _progressRow(
                    entry.key,
                    entry.value.where((p) => p.isCompleted).length / entry.value.length,
                    const Color(0xFF6C5CE7),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          tr(context, 'Son 4 həftə', 'Last 4 weeks'),
          style: poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (final week in weeks) ...[
                _progressRow(
                  '${week.$1.day}.${week.$1.month}',
                  week.$2 == 0 ? 0 : week.$3 / week.$2,
                  const Color(0xFF00CEC9),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressRow(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: poppins(fontSize: 14)),
            Text(
              '${(percent * 100).toInt()}%',
              style: poppins(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          lineHeight: 8,
          percent: percent,
          backgroundColor: color.withOpacity(0.15),
          progressColor: color,
          barRadius: const Radius.circular(4),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
