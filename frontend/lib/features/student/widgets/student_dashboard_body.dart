import 'package:flutter/material.dart';

import '../../../core/widgets/dashboard/dashboard_action_card.dart';
import '../../../core/widgets/dashboard/dashboard_header.dart';
import '../../../core/widgets/dashboard/dashboard_profile_card.dart';
import '../../../core/widgets/dashboard/dashboard_section_title.dart';
import '../../auth/models/user.dart';

class StudentDashboardBody extends StatelessWidget {
  final User user;

  const StudentDashboardBody({super.key, required this.user});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardHeader(
            greeting: _greeting(),
            name: user.fullName,
            roleLabel: 'Student',
            roleIcon: Icons.sports_martial_arts,
            gradientColors: const [
              Color(0xFF2E7D32),
              Color(0xFF66BB6A),
            ],
          ),
          const SizedBox(height: 24),
          const DashboardSectionTitle(
            title: 'Learning Hub',
            subtitle: 'Everything you need for your training journey',
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              DashboardActionCard(
                icon: Icons.class_rounded,
                title: 'My Classes',
                subtitle: 'View enrolled courses and schedules',
                color: Colors.green.shade700,
                comingSoon: true,
              ),
              DashboardActionCard(
                icon: Icons.assignment_rounded,
                title: 'Assignments',
                subtitle: 'Track homework and due dates',
                color: Colors.orange.shade700,
                comingSoon: true,
              ),
              DashboardActionCard(
                icon: Icons.library_books_rounded,
                title: 'Materials',
                subtitle: 'Access lesson notes and resources',
                color: Colors.blue.shade700,
                comingSoon: true,
              ),
              DashboardActionCard(
                icon: Icons.emoji_events_rounded,
                title: 'Progress',
                subtitle: 'Belt ranks, grades, and achievements',
                color: Colors.amber.shade800,
                comingSoon: true,
              ),
            ],
          ),
          const SizedBox(height: 28),
          const DashboardSectionTitle(
            title: 'Training Tips',
            subtitle: 'Discipline • Strength • Respect',
          ),
          const SizedBox(height: 12),
          _TipCard(
            icon: Icons.self_improvement_rounded,
            title: 'Stay consistent',
            description:
                'Regular practice builds muscle memory and discipline over time.',
            accentColor: Colors.green,
          ),
          const SizedBox(height: 10),
          _TipCard(
            icon: Icons.psychology_rounded,
            title: 'Focus on fundamentals',
            description:
                'Master the basics before advancing to more complex techniques.',
            accentColor: Colors.teal,
          ),
          const SizedBox(height: 28),
          const DashboardSectionTitle(title: 'Your Profile'),
          const SizedBox(height: 12),
          DashboardProfileCard(user: user),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final MaterialColor accentColor;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor.shade700, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
