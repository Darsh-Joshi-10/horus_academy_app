import 'package:flutter/material.dart';

import '../../../core/widgets/dashboard/dashboard_action_card.dart';
import '../../../core/widgets/dashboard/dashboard_header.dart';
import '../../../core/widgets/dashboard/dashboard_profile_card.dart';
import '../../../core/widgets/dashboard/dashboard_section_title.dart';
import '../../auth/models/user.dart';

class TeacherDashboardBody extends StatelessWidget {
  final User user;

  const TeacherDashboardBody({super.key, required this.user});

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
            roleLabel: 'Teacher',
            roleIcon: Icons.school_rounded,
            gradientColors: const [
              Color(0xFF1565C0),
              Color(0xFF42A5F5),
            ],
          ),
          const SizedBox(height: 24),
          const DashboardSectionTitle(
            title: 'Your Workspace',
            subtitle: 'Tools for teaching and student management',
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
                icon: Icons.menu_book_rounded,
                title: 'My Courses',
                subtitle: 'View and manage your assigned classes',
                color: Colors.blue.shade700,
                comingSoon: true,
              ),
              DashboardActionCard(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Grading',
                subtitle: 'Review submissions and record grades',
                color: Colors.green.shade700,
                comingSoon: true,
              ),
              DashboardActionCard(
                icon: Icons.upload_file_rounded,
                title: 'Materials',
                subtitle: 'Share lesson plans and resources',
                color: Colors.orange.shade700,
                comingSoon: true,
              ),
              DashboardActionCard(
                icon: Icons.calendar_today_rounded,
                title: 'Schedule',
                subtitle: 'View your class timetable',
                color: Colors.purple,
                comingSoon: true,
              ),
            ],
          ),
          const SizedBox(height: 28),
          const DashboardSectionTitle(
            title: 'Today\'s Focus',
            subtitle: 'Stay on top of your teaching duties',
          ),
          const SizedBox(height: 12),
          _FocusCard(
            icon: Icons.fitness_center_rounded,
            title: 'Prepare for class',
            description:
                'Review your lesson plan and materials before the next session.',
            color: Colors.blue.shade50,
            iconColor: Colors.blue.shade700,
          ),
          const SizedBox(height: 10),
          _FocusCard(
            icon: Icons.people_alt_rounded,
            title: 'Track student progress',
            description:
                'Monitor attendance and performance for each of your students.',
            color: Colors.green.shade50,
            iconColor: Colors.green.shade700,
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

class _FocusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color iconColor;

  const _FocusCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
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
