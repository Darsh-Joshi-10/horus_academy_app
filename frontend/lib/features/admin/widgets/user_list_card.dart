import 'package:flutter/material.dart';

import '../../auth/models/user.dart';

class UserListCard extends StatelessWidget {
  final User user;
  final VoidCallback? onSuspend;

  const UserListCard({
    super.key,
    required this.user,
    this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusStyle = _statusStyle(user.status);

    final initials =
        '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
            .toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _roleColor(user).withValues(alpha: 0.9),
                        _roleColor(user),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  label: user.status,
                  color: statusStyle.color,
                  backgroundColor: statusStyle.background,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.badge_outlined,
                  label: user.displayRole,
                  color: _roleColor(user),
                ),
                _InfoChip(
                  icon: Icons.phone_outlined,
                  label: user.phone,
                  color: colorScheme.primary,
                ),
                if (!user.isActive)
                  _InfoChip(
                    icon: Icons.block_rounded,
                    label: 'Inactive',
                    color: colorScheme.error,
                  ),
              ],
            ),
            if (onSuspend != null) ...[
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onSuspend,
                  icon: const Icon(Icons.pause_circle_outline_rounded, size: 18),
                  label: const Text('Suspend'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _roleColor(User user) {
    if (user.isAdmin) return Colors.deepPurple;
    if (user.isTeacher) return Colors.blue.shade700;
    return Colors.green.shade700;
  }

  ({Color color, Color background}) _statusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return (color: Colors.green.shade800, background: Colors.green.shade50);
      case 'PENDING':
        return (color: Colors.orange.shade800, background: Colors.orange.shade50);
      case 'REJECTED':
        return (color: Colors.red.shade800, background: Colors.red.shade50);
      case 'SUSPENDED':
        return (color: Colors.grey.shade800, background: Colors.grey.shade100);
      default:
        return (color: Colors.grey.shade800, background: Colors.grey.shade100);
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
