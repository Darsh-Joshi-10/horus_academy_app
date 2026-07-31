import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/user.dart';
import '../providers/all_users_provider.dart';
import '../widgets/user_list_card.dart';

enum _StatusFilter { all, approved, pending, rejected, suspended }

enum _RoleFilter { all, admin, teacher, student }

class AllUsersScreen extends ConsumerStatefulWidget {
  const AllUsersScreen({super.key});

  @override
  ConsumerState<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends ConsumerState<AllUsersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  _StatusFilter _statusFilter = _StatusFilter.all;
  _RoleFilter _roleFilter = _RoleFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<User> _filterUsers(List<User> users) {
    return users.where((user) {
      if (_searchQuery.isNotEmpty) {
        final haystack =
            '${user.fullName} ${user.email} ${user.phone} ${user.displayRole}'
                .toLowerCase();
        if (!haystack.contains(_searchQuery)) return false;
      }

      switch (_statusFilter) {
        case _StatusFilter.approved:
          if (user.status.toUpperCase() != 'APPROVED') return false;
        case _StatusFilter.pending:
          if (user.status.toUpperCase() != 'PENDING') return false;
        case _StatusFilter.rejected:
          if (user.status.toUpperCase() != 'REJECTED') return false;
        case _StatusFilter.suspended:
          if (user.status.toUpperCase() != 'SUSPENDED') return false;
        case _StatusFilter.all:
          break;
      }

      switch (_roleFilter) {
        case _RoleFilter.admin:
          if (!user.isAdmin) return false;
        case _RoleFilter.teacher:
          if (!user.isTeacher) return false;
        case _RoleFilter.student:
          if (!user.isStudent) return false;
        case _RoleFilter.all:
          break;
      }

      return true;
    }).toList();
  }

  bool _canSuspend(User user) {
    return user.status.toUpperCase() == 'APPROVED' && !user.isAdmin;
  }

  void _confirmSuspend(User user) {
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
            child: Icon(
              Icons.pause_circle_outline_rounded,
              color: colorScheme.onErrorContainer,
              size: 28,
            ),
          ),
          title: Text(
            'Suspend User?',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Are you sure you want to suspend ${user.fullName}? They will no longer be able to log in.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
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
                  await ref.read(allUsersProvider.notifier).suspendUser(user.id);
                  if (mounted) {
                    _showSuccessSnackbar('${user.fullName} has been suspended.');
                  }
                } catch (e) {
                  if (mounted) _showErrorSnackbar(e.toString());
                }
              },
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              child: const Text('Suspend'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackbar(String message) {
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

  void _showErrorSnackbar(String message) {
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

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(allUsersProvider);
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
              'All Users',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            usersState.whenOrNull(
                  data: (users) => Text(
                    '${users.length} total ${users.length == 1 ? 'member' : 'members'}',
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
        error: (error, _) => _buildErrorState(error.toString(), colorScheme, theme),
        data: (users) {
          final filtered = _filterUsers(users);

          return Column(
            children: [
              _buildFilters(colorScheme, theme, filtered.length, users.length),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(theme, colorScheme, users.isEmpty)
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(allUsersProvider.notifier).loadAllUsers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 4, bottom: 24),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final user = filtered[index];
                            return UserListCard(
                              user: user,
                              onSuspend: _canSuspend(user)
                                  ? () => _confirmSuspend(user)
                                  : null,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(
    ColorScheme colorScheme,
    ThemeData theme,
    int filteredCount,
    int totalCount,
  ) {
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or phone…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () => _searchController.clear(),
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Status',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _StatusFilter.values.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_statusLabel(filter)),
                    selected: _statusFilter == filter,
                    onSelected: (_) => setState(() => _statusFilter = filter),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Role',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _RoleFilter.values.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_roleLabel(filter)),
                    selected: _roleFilter == filter,
                    onSelected: (_) => setState(() => _roleFilter = filter),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          if (filteredCount != totalCount) ...[
            const SizedBox(height: 10),
            Text(
              'Showing $filteredCount of $totalCount users',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(_StatusFilter filter) {
    switch (filter) {
      case _StatusFilter.all:
        return 'All';
      case _StatusFilter.approved:
        return 'Approved';
      case _StatusFilter.pending:
        return 'Pending';
      case _StatusFilter.rejected:
        return 'Rejected';
      case _StatusFilter.suspended:
        return 'Suspended';
    }
  }

  String _roleLabel(_RoleFilter filter) {
    switch (filter) {
      case _RoleFilter.all:
        return 'All Roles';
      case _RoleFilter.admin:
        return 'Admin';
      case _RoleFilter.teacher:
        return 'Teacher';
      case _RoleFilter.student:
        return 'Student';
    }
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading users…',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ColorScheme colorScheme, ThemeData theme) {
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
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              onPressed: () => ref.read(allUsersProvider.notifier).loadAllUsers(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme, bool noUsersAtAll) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                noUsersAtAll ? Icons.groups_outlined : Icons.search_off_rounded,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              noUsersAtAll ? 'No users yet' : 'No matching users',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              noUsersAtAll
                  ? 'Registered academy members will appear here.'
                  : 'Try adjusting your search or filters.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
