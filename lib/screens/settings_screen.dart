import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/poppins.dart';
import '../services/plan_service.dart';
import '../models/plan_item.dart';
import '../services/reminder_service.dart';
import '../services/timetable_export.dart';
import 'premium_screen.dart';
import 'privacy_policy_screen.dart';
import '../l10n/tr.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PlanService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Parametrlər', 'Settings'), style: poppins()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.isPremium
                              ? tr(context, 'Premium aktivdir', 'Premium is active')
                              : tr(context, 'Cədvəl Premium', 'Cedvel Premium'),
                          style: poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          service.isPremium
                              ? tr(context, 'Bütün funksiyalar açıqdır', 'Every feature is unlocked')
                              : tr(context, 'Limitsiz plan + əlavə xüsusiyyətlər', 'Unlimited plans + extra features'),
                          style: poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(tr(context, 'Profil', 'Profile')),
          _tile(Icons.person_outline, tr(context, 'Ad', 'Name'), trailing: service.userName.isEmpty ? '—' : service.userName, onTap: () {
            _editName(context, service);
          }),
          const SizedBox(height: 16),
          _sectionTitle(tr(context, 'Ümumi', 'General')),
          _tile(Icons.dark_mode_outlined, tr(context, 'Tema', 'Theme'), trailing: _themeLabel(service.themeMode, service.english), onTap: () {
            _selectTheme(context, service);
          }),
          _tile(Icons.category_outlined, tr(context, 'Kateqoriyalar', 'Categories'), trailing: '${service.categories.length}', onTap: () {
            _manageCategories(context, service);
          }),
          _tile(
            Icons.language,
            tr(context, 'Dil', 'Language'),
            trailing: service.english ? 'English' : 'Azərbaycan',
            onTap: () => _pickLanguage(context, service),
          ),
          const SizedBox(height: 16),
          _sectionTitle(tr(context, 'Cədvəl', 'Timetable')),
          _tile(
            Icons.view_week_outlined,
            tr(context, 'Həftənin başlanğıcı', 'Week starts on'),
            trailing: weekdayLong(service.weekStartsOn, en: service.english),
            onTap: () => _pickWeekStart(context, service),
          ),
          _tile(
            Icons.image_outlined,
            tr(context, 'Cədvəli şəkil kimi yüklə', 'Save timetable as image'),
            trailing: 'PNG',
            onTap: () => TimetableExport.showSheet(
              context,
              plans: service.plans,
              weekStart: service.weekStart(),
              userName: service.userName,
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle(tr(context, 'Bildirişlər', 'Notifications')),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(tr(context, 'Dərs xəbərdarlığı', 'Lesson reminders'), style: poppins()),
            value: service.remindersEnabled,
            onChanged: (v) => service.setRemindersEnabled(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: Text(tr(context, 'Səs', 'Sound'), style: poppins()),
            value: service.soundEnabled,
            onChanged: (v) => service.setSoundEnabled(v),
          ),
          ListTile(
            leading: const Icon(Icons.notification_important_outlined),
            title: Text(tr(context, 'Bildirişi sına', 'Test notification'), style: poppins()),
            onTap: () {
              ReminderService.instance.fireTest(sound: service.soundEnabled);
            },
          ),
          const SizedBox(height: 16),
          _sectionTitle(tr(context, 'Məlumat', 'Data')),
          _tile(Icons.delete_outline, tr(context, 'Bütün planları sil', 'Delete all plans'), onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(tr(context, 'Təsdiq', 'Confirm')),
                content: Text(tr(context, 'Bütün planlar silinəcək. Əminsiniz?', 'All plans will be deleted. Are you sure?')),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr(context, 'Xeyr', 'No'))),
                  TextButton(
                    onPressed: () {
                      service.clearAllPlans();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(trRead(context, 'Bütün planlar silindi', 'All plans deleted'))),
                      );
                    },
                    child: Text(tr(context, 'Bəli', 'Yes'), style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          _sectionTitle(tr(context, 'Hüquqi', 'Legal')),
          _tile(Icons.privacy_tip_outlined, tr(context, 'Məxfilik Siyasəti', 'Privacy Policy'), onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            );
          }),
          const SizedBox(height: 16),
          _sectionTitle(tr(context, 'Haqqında', 'About')),
          _tile(Icons.info_outline, tr(context, 'Versiya', 'Version'), trailing: '1.3.0'),
          _tile(Icons.code, 'Nibras Code', trailing: 'Developer'),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Cədvəl • Gününə nəzarət et\nNibras Code',
              textAlign: TextAlign.center,
              style: poppins(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode, bool en) {
    switch (mode) {
      case ThemeMode.light:
        return en ? 'Light' : 'Açıq';
      case ThemeMode.dark:
        return en ? 'Dark' : 'Qaranlıq';
      default:
        return en ? 'System' : 'Sistem';
    }
  }

  void _editName(BuildContext context, PlanService service) {
    final controller = TextEditingController(text: service.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr(context, 'Adınız', 'Your name'), style: poppins()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: tr(context, 'Məsələn: Rəşad', 'For example: Rashad')),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr(context, 'Ləğv', 'Cancel'))),
          TextButton(
            onPressed: () {
              service.setUserName(controller.text);
              Navigator.pop(ctx);
            },
            child: Text(tr(context, 'Saxla', 'Save')),
          ),
        ],
      ),
    );
  }

  void _selectTheme(BuildContext context, PlanService service) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(tr(context, 'Sistem', 'System')),
              leading: const Icon(Icons.brightness_auto),
              onTap: () {
                service.setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(tr(context, 'Açıq', 'Light')),
              leading: const Icon(Icons.light_mode),
              onTap: () {
                service.setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(tr(context, 'Qaranlıq', 'Dark')),
              leading: const Icon(Icons.dark_mode),
              onTap: () {
                service.setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _manageCategories(BuildContext context, PlanService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final controller = TextEditingController();
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr(context, 'Kateqoriyalar', 'Categories'), style: poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: service.categories.map((c) {
                      return Chip(
                        label: Text(c),
                        onDeleted: () {
                          service.removeCategory(c);
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: tr(context, 'Yeni kateqoriya', 'New category'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          service.addCategory(controller.text);
                          controller.clear();
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.add_circle, color: Color(0xFF6C5CE7)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _pickLanguage(BuildContext context, PlanService service) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Azərbaycan'),
              trailing: !service.english ? const Icon(Icons.check, color: Color(0xFF6C5CE7)) : null,
              onTap: () {
                service.setLocale('az');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: service.english ? const Icon(Icons.check, color: Color(0xFF6C5CE7)) : null,
              onTap: () {
                service.setLocale('en');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickWeekStart(BuildContext context, PlanService service) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var day = 1; day <= 7; day++)
              ListTile(
                title: Text(weekdayLong(day, en: service.english)),
                trailing: service.weekStartsOn == day
                    ? const Icon(Icons.check, color: Color(0xFF6C5CE7))
                    : null,
                onTap: () {
                  service.setWeekStartsOn(day);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        text,
        style: poppins(
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, {String? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: poppins()),
      trailing: trailing != null
          ? Text(trailing, style: poppins(color: Colors.grey))
          : const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
