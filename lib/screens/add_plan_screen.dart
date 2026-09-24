import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/poppins.dart';
import 'package:intl/intl.dart';
import '../models/plan_item.dart';
import '../services/plan_service.dart';
import '../services/reminder_service.dart';
import '../l10n/tr.dart';
import 'premium_screen.dart';

class AddPlanScreen extends StatefulWidget {
  final PlanItem? plan;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const AddPlanScreen({
    super.key,
    this.plan,
    this.initialStart,
    this.initialEnd,
  });

  @override
  State<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends State<AddPlanScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _locationController;
  late final TextEditingController _noteController;

  late DateTime _start;
  late DateTime _end;
  late PlanType _type;
  late String _category;
  late Color _color;
  int? _reminderOffsetMin;
  bool _repeatWeekly = false;

  final List<Color> _colors = const [
    Color(0xFF6C5CE7),
    Color(0xFF00CEC9),
    Color(0xFFE17055),
    Color(0xFFFDCB6E),
    Color(0xFF00B894),
    Color(0xFFA29BFE),
    Color(0xFFFD79A8),
  ];

  bool get _editing => widget.plan != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _titleController = TextEditingController(text: p?.title ?? '');
    _subtitleController = TextEditingController(text: p?.subtitle ?? '');
    _locationController = TextEditingController(text: p?.location ?? '');
    _noteController = TextEditingController(text: p?.note ?? '');
    _start = p?.startTime ??
        widget.initialStart ??
        DateTime.now().add(const Duration(hours: 1));
    _end = p?.endTime ??
        widget.initialEnd ??
        _start.add(const Duration(hours: 1));
    _type = p?.type ?? PlanType.lesson;
    _category = p?.category ?? 'Dərs';
    _color = p?.color ?? const Color(0xFF6C5CE7);
    _reminderOffsetMin = p != null ? p.reminderOffsetMin : 10;
    _repeatWeekly = p?.repeatWeekly ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _start : _end),
    );
    if (time == null) return;
    setState(() {
      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        _start = dt;
        if (!_end.isAfter(_start)) {
          _end = _start.add(const Duration(hours: 1));
        }
      } else {
        _end = dt;
      }
    });
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(trRead(context, 'Başlıq daxil edin', 'Enter a title'))),
      );
      return;
    }
    final service = context.read<PlanService>();
    if (!_editing && !service.canAddPlan) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );
      return;
    }
    final item = PlanItem(
      id: widget.plan?.id,
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isEmpty
          ? null
          : _subtitleController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      startTime: _start,
      endTime: _end.isAfter(_start) ? _end : _start.add(const Duration(hours: 1)),
      type: _type,
      category: _category,
      color: _color,
      isCompleted: widget.plan?.isCompleted ?? false,
      reminderOffsetMin: _reminderOffsetMin,
      repeatWeekly: _repeatWeekly,
    );
    if (_editing) {
      service.updatePlan(item);
    } else {
      service.addPlan(item);
    }
    if (_reminderOffsetMin != null) {
      await ReminderService.instance.requestPermission();
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PlanService>();
    final en = service.english;
    final loc = en ? 'en' : 'az';
    String typeLabel(PlanType t) {
      switch (t) {
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
        title: Text(
          _editing ? tr(context, 'Planı redaktə et', 'Edit plan') : tr(context, 'Yeni plan', 'New plan'),
          style: poppins(),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              tr(context, 'Saxla', 'Save'),
              style: poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6C5CE7),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: tr(context, 'Başlıq *', 'Title *'),
                hintText: tr(context, 'Məsələn: Hesab dərsi', 'For example: Calculus'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _subtitleController,
              decoration: InputDecoration(
                labelText: tr(context, 'Alt başlıq', 'Subtitle'),
                hintText: tr(context, 'Məsələn: Riyaziyyat', 'For example: Math'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: tr(context, 'Məkan', 'Place'),
                hintText: tr(context, 'Sinif 301', 'Room 301'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _timeButton(
                    tr(context, 'Başlama', 'Start'),
                    DateFormat('dd MMM HH:mm', loc).format(_start),
                    () => _pickDateTime(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _timeButton(
                    tr(context, 'Bitmə', 'End'),
                    DateFormat('dd MMM HH:mm', loc).format(_end),
                    () => _pickDateTime(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(tr(context, 'Növ', 'Type'), style: poppins(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 8,
              children: PlanType.values.map((t) {
                return ChoiceChip(
                  label: Text(typeLabel(t)),
                  selected: _type == t,
                  onSelected: (_) => setState(() {
                    _type = t;
                    if (t == PlanType.lesson && _reminderOffsetMin == null) {
                      _reminderOffsetMin = 10;
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              _type == PlanType.lesson
                  ? tr(context, 'Dərs xəbərdarlığı', 'Lesson reminder')
                  : tr(context, 'Xəbərdarlıq', 'Reminder'),
              style: poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _reminderOffsetMin ?? -1,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: reminderChoices(en: en).entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                _reminderOffsetMin = (v == null || v < 0) ? null : v;
              }),
            ),
            const SizedBox(height: 6),
            Text(
              tr(
                context,
                'Vaxtı çatanda bildiriş yuxarıda açılır və səs çıxır.',
                'When it is time, a notification appears and a sound plays.',
              ),
              style: poppins(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                tr(context, 'Hər həftə təkrarla', 'Repeat every week'),
                style: poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                tr(
                  context,
                  'Eyni gün və saat növbəti həftələrdə də görünür.',
                  'Same weekday and time shows on later weeks too.',
                ),
                style: poppins(fontSize: 12, color: Colors.grey),
              ),
              value: _repeatWeekly,
              onChanged: (v) => setState(() => _repeatWeekly = v),
            ),
            const SizedBox(height: 8),
            Text(tr(context, 'Kateqoriya', 'Category'), style: poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: service.categories.contains(_category)
                  ? _category
                  : (service.categories.isEmpty ? null : service.categories.first),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                ...service.categories.map(
                  (c) => DropdownMenuItem(value: c, child: Text(c)),
                ),
                if (!service.categories.contains(_category))
                  DropdownMenuItem(value: _category, child: Text(_category)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 16),
            Text(tr(context, 'Rəng', 'Color'), style: poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: _colors.map((c) {
                final selected = _color == c;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.black87, width: 3)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: tr(context, 'Qeyd', 'Note'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(_editing ? tr(context, 'Dəyişiklikləri saxla', 'Save changes') : tr(context, 'Planı saxla', 'Save plan')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeButton(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: poppins(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: poppins(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
