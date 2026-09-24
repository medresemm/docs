import 'package:flutter/material.dart';
import '../theme/poppins.dart';
import 'package:provider/provider.dart';
import '../services/plan_service.dart';
import '../l10n/tr.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _page = 0;

  final _pages = const [
    _OnboardData(icon: Icons.calendar_today_rounded),
    _OnboardData(icon: Icons.insights_rounded),
    _OnboardData(icon: Icons.workspace_premium_rounded),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _finish() {
    final service = context.read<PlanService>();
    if (_nameController.text.trim().isNotEmpty) {
      service.setUserName(_nameController.text.trim());
    }
    service.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(tr(context, 'Keç', 'Skip'), style: poppins(color: Colors.grey)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length + 1,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  if (index < _pages.length) {
                    final p = _pages[index];
                    final titles = [
                      tr(context, 'Gününü planla', 'Plan your day'),
                      tr(context, 'İrəliləyişini gör', 'See your progress'),
                      tr(context, 'Premium ilə daha çox', 'More with Premium'),
                    ];
                    final subtitles = [
                      tr(context, 'Dərs, tapşırıq və tədbirlərini bir yerdə saxla. Sadə və aydın.', 'Keep lessons, tasks and events in one place.'),
                      tr(context, 'Statistika ilə nə qədər tamamladığını izlə. Motivasiya üçün kifayətdir.', 'Track how much you finish. Enough to stay motivated.'),
                      tr(context, 'Limitsiz plan, kateqoriyalar və təkmil statistika.', 'Unlimited plans, categories and advanced stats.'),
                    ];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(p.icon, size: 48, color: const Color(0xFF6C5CE7)),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            titles[index],
                            textAlign: TextAlign.center,
                            style: poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            subtitles[index],
                            textAlign: TextAlign.center,
                            style: poppins(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  // Name page
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tr(context, 'Sənə necə müraciət edək?', 'What should we call you?'),
                          textAlign: TextAlign.center,
                          style: poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr(context, 'Adın ana səhifədə görünəcək', 'Your name shows on the home screen'),
                          style: poppins(color: Colors.grey),
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: poppins(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: tr(context, 'Məsələn: Rəşad', 'For example: Rashad'),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length + 1, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? const Color(0xFF6C5CE7)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_page < _pages.length) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _finish();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _page < _pages.length ? tr(context, 'Davam et', 'Continue') : tr(context, 'Başla', 'Start'),
                    style: poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final IconData icon;
  const _OnboardData({required this.icon});
}
