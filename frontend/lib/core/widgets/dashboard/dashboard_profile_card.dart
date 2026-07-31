import 'package:flutter/material.dart';

import '../../../features/auth/models/user.dart';

class DashboardProfileCard extends StatelessWidget {
  final User user;

  const DashboardProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _ProfileRow(
            icon: Icons.person_outline_rounded,
            label: 'Name',
            value: user.fullName,
          ),
          _divider(colorScheme),
          _ProfileRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          _divider(colorScheme),
          _ProfileRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone,
          ),
          _divider(colorScheme),
          _ProfileRow(
            icon: Icons.badge_outlined,
            label: 'Role',
            value: user.displayRole,
          ),
          _divider(colorScheme),
          _ProfileRow(
            icon: Icons.verified_user_outlined,
            label: 'Status',
            value: user.status,
            valueColor: user.status.toUpperCase() == 'APPROVED'
                ? Colors.green.shade700
                : null,
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      indent: 56,
      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? colorScheme.onSurface,
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
