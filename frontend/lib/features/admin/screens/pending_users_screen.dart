import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/user.dart';
import '../../branches/models/branch_model.dart';
import '../../branches/providers/branches_provider.dart';
import '../models/role_model.dart';
import '../providers/pending_users_provider.dart';
import '../providers/roles_provider.dart';
import '../widgets/pending_user_card.dart';

class PendingUsersScreen extends ConsumerWidget {
  const PendingUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(pendingUsersProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'User Approvals',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            usersState.whenOrNull(
                  data: (users) => Text(
                    '${users.length} pending ${users.length == 1 ? 'request' : 'requests'}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ) ??
                const SizedBox.shrink(),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      body: usersState.when(
        loading: () => _buildLoadingState(colorScheme),
        error: (error, _) => _buildErrorState(context, ref, error.toString(), colorScheme, theme),
        data: (users) {
          if (users.isEmpty) {
            return _buildEmptyState(context, ref, colorScheme, theme);
          }
          return _buildUserList(context, ref, users);
        },
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading pending users…',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String error,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => ref.read(pendingUsersProvider.notifier).loadPendingUsers(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All caught up!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no pending registrations to review right now.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => ref.read(pendingUsersProvider.notifier).loadPendingUsers(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context, WidgetRef ref, List<User> users) {
    return RefreshIndicator(
      onRefresh: () => ref.read(pendingUsersProvider.notifier).loadPendingUsers(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return PendingUserCard(
            user: user,
            onApprove: () => _showRoleBottomSheet(context, ref, user),
            onReject: () => _showRejectConfirmation(context, ref, user),
          );
        },
      ),
    );
  }

  // ─── Role Assignment Bottom Sheet ─────────────────────────────────────────

  void _showRoleBottomSheet(BuildContext context, WidgetRef ref, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ApprovalSheet(
        user: user,
        onConfirm: (roleId, branchId) async {
          Navigator.pop(ctx);
          await _approveWithFeedback(
            context,
            ref,
            user.id,
            roleId,
            branchId,
            user.fullName,
          );
        },
      ),
    );
  }

  Future<void> _approveWithFeedback(
    BuildContext context,
    WidgetRef ref,
    String userId,
    int roleId,
    String branchId,
    String userName,
  ) async {
    try {
      await ref.read(pendingUsersProvider.notifier).approveUser(
            userId,
            roleId,
            branchId: branchId,
          );
      if (context.mounted) {
        _showSuccessSnackbar(
          context,
          '$userName has been approved successfully.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, e.toString());
      }
    }
  }

  // ─── Reject Confirmation Dialog ────────────────────────────────────────────

  void _showRejectConfirmation(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_remove_rounded, color: colorScheme.onErrorContainer, size: 28),
          ),
          title: Text(
            'Reject Registration?',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Are you sure you want to reject ${user.fullName}\'s registration request? This action cannot be undone.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await ref.read(pendingUsersProvider.notifier).rejectUser(user.id);
                  if (context.mounted) {
                    _showSuccessSnackbar(
                      context,
                      '${user.fullName}\'s registration has been rejected.',
                    );
                  }
                } catch (e) {
                  if (context.mounted) _showErrorSnackbar(context, e.toString());
                }
              },
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  // ─── Snackbars ─────────────────────────────────────────────────────────────

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ─── Approval Bottom Sheet (Role + Branch) ────────────────────────────────────

class _ApprovalSheet extends ConsumerStatefulWidget {
  final User user;
  final Future<void> Function(int roleId, String branchId) onConfirm;

  const _ApprovalSheet({
    required this.user,
    required this.onConfirm,
  });

  @override
  ConsumerState<_ApprovalSheet> createState() => _ApprovalSheetState();
}

class _ApprovalSheetState extends ConsumerState<_ApprovalSheet> {
  int? _selectedRoleId;
  String? _selectedBranchId;

  static const _fallbackRoles = [
    _RoleOption(
      id: 3,
      name: 'Student',
      description: 'Can access courses, materials, and assignments.',
      icon: Icons.school_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF818CF8)],
    ),
    _RoleOption(
      id: 2,
      name: 'Teacher',
      description: 'Can manage courses, grade students, and post materials.',
      icon: Icons.cast_for_education_rounded,
      gradientColors: [Color(0xFF0891B2), Color(0xFF22D3EE)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.user.branchId != null && widget.user.branchId!.isNotEmpty) {
      _selectedBranchId = widget.user.branchId;
    }
  }

  _RoleOption _mapRoleToOption(Role role) {
    final nameLower = role.name.toLowerCase();
    if (nameLower.contains('admin')) {
      return _RoleOption(
        id: role.id,
        name: role.name,
        description: role.description ?? 'Full system access and admin privileges.',
        icon: Icons.admin_panel_settings_rounded,
        gradientColors: const [Color(0xFFEA580C), Color(0xFFF97316)],
      );
    } else if (nameLower.contains('teacher')) {
      return _RoleOption(
        id: role.id,
        name: role.name,
        description: role.description ?? 'Can manage courses, grade students, and post materials.',
        icon: Icons.cast_for_education_rounded,
        gradientColors: const [Color(0xFF0891B2), Color(0xFF22D3EE)],
      );
    } else if (nameLower.contains('student')) {
      return _RoleOption(
        id: role.id,
        name: role.name,
        description: role.description ?? 'Can access courses, materials, and assignments.',
        icon: Icons.school_rounded,
        gradientColors: const [Color(0xFF6366F1), Color(0xFF818CF8)],
      );
    }

    return _RoleOption(
      id: role.id,
      name: role.name,
      description: role.description ?? 'Standard user permissions.',
      icon: Icons.person_outline_rounded,
      gradientColors: const [Color(0xFF4B5563), Color(0xFF9CA3AF)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final initials =
        '${widget.user.firstName.isNotEmpty ? widget.user.firstName[0] : ''}${widget.user.lastName.isNotEmpty ? widget.user.lastName[0] : ''}'
            .toUpperCase();

    final asyncRoles = ref.watch(rolesProvider);
    final asyncBranches = ref.watch(activeBranchesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.tertiary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Approve registration for',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            widget.user.fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Text(
                        'Select a role',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      asyncRoles.when(
                        data: (fetchedRoles) {
                          final options = fetchedRoles.isEmpty
                              ? _fallbackRoles
                              : fetchedRoles.map(_mapRoleToOption).toList();
                          return Column(
                            children: options
                                .map((role) => _buildRoleCard(context, role, colorScheme, theme))
                                .toList(),
                          );
                        },
                        loading: () => Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: CircularProgressIndicator(color: colorScheme.primary),
                          ),
                        ),
                        error: (err, stack) => Column(
                          children: _fallbackRoles
                              .map((role) => _buildRoleCard(context, role, colorScheme, theme))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Assign a branch',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      asyncBranches.when(
                        data: (branches) {
                          if (branches.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'No active branches available. Create a branch first.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: branches
                                .map((branch) => _buildBranchCard(context, branch, colorScheme, theme))
                                .toList(),
                          );
                        },
                        loading: () => Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: CircularProgressIndicator(color: colorScheme.primary),
                          ),
                        ),
                        error: (err, stack) => Text(
                          'Failed to load branches.',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildConfirmButton(asyncRoles, asyncBranches),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(
    AsyncValue<List<Role>> asyncRoles,
    AsyncValue<List<Branch>> asyncBranches,
  ) {
    final canApprove = _selectedRoleId != null &&
        _selectedBranchId != null &&
        asyncBranches.maybeWhen(data: (b) => b.isNotEmpty, orElse: () => false);

    var buttonLabel = 'Choose a role and branch to continue';
    if (_selectedRoleId != null && _selectedBranchId != null) {
      final roleName = _resolveRoleName(asyncRoles, _selectedRoleId!);
      final branchName = _resolveBranchName(asyncBranches, _selectedBranchId!);
      buttonLabel = 'Approve as $roleName · $branchName';
    } else if (_selectedRoleId != null) {
      buttonLabel = 'Choose a branch to continue';
    }

    return FilledButton(
      onPressed: !canApprove
          ? null
          : () => widget.onConfirm(_selectedRoleId!, _selectedBranchId!),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              buttonLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _resolveRoleName(AsyncValue<List<Role>> asyncRoles, int roleId) {
    return asyncRoles.maybeWhen(
      data: (roles) {
        if (roles.isEmpty) {
          return _fallbackRoles.firstWhere((r) => r.id == roleId, orElse: () => _fallbackRoles.first).name;
        }
        return roles.firstWhere((r) => r.id == roleId, orElse: () => roles.first).name;
      },
      orElse: () => 'User',
    );
  }

  String _resolveBranchName(AsyncValue<List<Branch>> asyncBranches, String branchId) {
    return asyncBranches.maybeWhen(
      data: (branches) {
        return branches.firstWhere((b) => b.id == branchId, orElse: () => branches.first).name;
      },
      orElse: () => 'Branch',
    );
  }

  Widget _buildBranchCard(
    BuildContext context,
    Branch branch,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final isSelected = _selectedBranchId == branch.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedBranchId = branch.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.secondaryContainer.withValues(alpha: 0.5)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.secondary
                  : colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple.shade600, Colors.deepPurple.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      branch.branchCode,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? colorScheme.secondary : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${branch.city}, ${branch.state}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colorScheme.secondary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? colorScheme.secondary : colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check_rounded, size: 14, color: colorScheme.onSecondary)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    _RoleOption role,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final isSelected = _selectedRoleId == role.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedRoleId = role.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Gradient icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: role.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(role.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? colorScheme.primary : colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Role Option Data Class ─────────────────────────────────────────────────

class _RoleOption {
  final int id;
  final String name;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  const _RoleOption({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}
