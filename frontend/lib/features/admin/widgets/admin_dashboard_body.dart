import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/dashboard/dashboard_action_card.dart';
import '../../../core/widgets/dashboard/dashboard_header.dart';
import '../../../core/widgets/dashboard/dashboard_profile_card.dart';
import '../../../core/widgets/dashboard/dashboard_section_title.dart';
import '../../../core/widgets/dashboard/dashboard_stat_card.dart';
import '../../auth/models/user.dart';
import '../../branches/providers/branches_provider.dart';
import '../../branches/screens/branch_list_screen.dart';
import '../providers/all_users_provider.dart';
import '../providers/pending_users_provider.dart';
import '../screens/all_users_screen.dart';
import '../screens/pending_users_screen.dart';

class AdminDashboardBody extends ConsumerWidget {
  final User user;

  const AdminDashboardBody({super.key, required this.user});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingState = ref.watch(pendingUsersProvider);
    final branchesState = ref.watch(branchesProvider);
    final allUsersState = ref.watch(allUsersProvider);

    final pendingCount = pendingState.maybeWhen(
      data: (users) => users.length.toString(),
      orElse: () => '—',
    );
    final branchCount = branchesState.maybeWhen(
      data: (branches) => branches.length.toString(),
      orElse: () => '—',
    );
    final userCount = allUsersState.maybeWhen(
      data: (users) => users.length.toString(),
      orElse: () => '—',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardHeader(
            greeting: _greeting(),
            name: user.fullName,
            roleLabel: 'Administrator',
            roleIcon: Icons.admin_panel_settings_rounded,
            gradientColors: const [
              Color(0xFF5E35B1),
              Color(0xFF7E57C2),
            ],
          ),
          const SizedBox(height: 24),
          const DashboardSectionTitle(
            title: 'Overview',
            subtitle: 'Academy at a glance',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  icon: Icons.groups_rounded,
                  label: 'Total Users',
                  value: userCount,
                  color: Colors.teal,
                  isLoading: allUsersState.isLoading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardStatCard(
                  icon: Icons.pending_actions_rounded,
                  label: 'Pending',
                  value: pendingCount,
                  color: Colors.amber.shade700,
                  isLoading: pendingState.isLoading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardStatCard(
                  icon: Icons.location_city_rounded,
                  label: 'Branches',
                  value: branchCount,
                  color: Colors.deepPurple,
                  isLoading: branchesState.isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const DashboardSectionTitle(
            title: 'Quick Actions',
            subtitle: 'Manage users and academy locations',
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
                icon: Icons.person_add_alt_1_rounded,
                title: 'Pending Users',
                subtitle: 'Review and approve new registrations',
                color: Colors.amber.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PendingUsersScreen(),
                    ),
                  );
                },
              ),
              DashboardActionCard(
                icon: Icons.location_city_rounded,
                title: 'Branches',
                subtitle: 'Create and manage academy branches',
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BranchListScreen(),
                    ),
                  );
                },
              ),
              DashboardActionCard(
                icon: Icons.groups_rounded,
                title: 'All Users',
                subtitle: 'View and manage all academy members',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllUsersScreen(),
                    ),
                  );
                },
              ),
              DashboardActionCard(
                icon: Icons.analytics_outlined,
                title: 'Reports',
                subtitle: 'Enrollment and activity insights',
                color: Colors.indigo,
                comingSoon: true,
              ),
            ],
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
