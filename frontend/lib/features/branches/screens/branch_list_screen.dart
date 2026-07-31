import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/branch_model.dart';
import '../providers/branches_provider.dart';
import '../widgets/branch_card.dart';
import '../widgets/branch_form_dialog.dart';

class BranchListScreen extends ConsumerStatefulWidget {
  const BranchListScreen({super.key});

  @override
  ConsumerState<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends ConsumerState<BranchListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

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

  List<Branch> _filterBranches(List<Branch> branches) {
    if (_searchQuery.isEmpty) return branches;
    return branches.where((b) {
      return b.name.toLowerCase().contains(_searchQuery) ||
          b.branchCode.toLowerCase().contains(_searchQuery) ||
          b.city.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<void> _showCreateDialog() async {
    await BranchFormDialog.show(
      context,
      onSubmit: (data) async {
        try {
          await ref.read(branchesProvider.notifier).createBranch(data);
          if (mounted) {
            _showSuccessSnackbar('Branch created successfully.');
          }
        } catch (e) {
          if (mounted) _showErrorSnackbar(e.toString());
          rethrow;
        }
      },
    );
  }

  Future<void> _showEditDialog(Branch branch) async {
    await BranchFormDialog.show(
      context,
      branch: branch,
      onSubmit: (data) async {
        try {
          await ref.read(branchesProvider.notifier).updateBranch(branch.id, data);
          if (mounted) {
            _showSuccessSnackbar('${branch.name} updated successfully.');
          }
        } catch (e) {
          if (mounted) _showErrorSnackbar(e.toString());
          rethrow;
        }
      },
    );
  }

  void _confirmDelete(Branch branch) {
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
            child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer, size: 28),
          ),
          title: Text(
            'Delete Branch?',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Are you sure you want to delete "${branch.name}"? This action cannot be undone.',
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
                  await ref.read(branchesProvider.notifier).deleteBranch(branch.id);
                  if (mounted) {
                    _showSuccessSnackbar('${branch.name} has been deleted.');
                  }
                } catch (e) {
                  if (mounted) _showErrorSnackbar(e.toString());
                }
              },
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleActive(Branch branch) async {
    try {
      await ref.read(branchesProvider.notifier).toggleActive(branch);
      if (mounted) {
        _showSuccessSnackbar(
          branch.isActive
              ? '${branch.name} has been deactivated.'
              : '${branch.name} has been activated.',
        );
      }
    } catch (e) {
      if (mounted) _showErrorSnackbar(e.toString());
    }
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
    final branchesState = ref.watch(branchesProvider);
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
              'Branch Management',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            branchesState.whenOrNull(
                  data: (branches) => Text(
                    '${branches.length} ${branches.length == 1 ? 'branch' : 'branches'}',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Branch'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, code, or city…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: branchesState.when(
              loading: () => _buildLoadingState(colorScheme),
              error: (error, _) => _buildErrorState(error.toString(), colorScheme, theme),
              data: (branches) {
                final filtered = _filterBranches(branches);
                if (filtered.isEmpty) {
                  return _buildEmptyState(colorScheme, theme, branches.isEmpty);
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(branchesProvider.notifier).loadBranches(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 88),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final branch = filtered[index];
                      return BranchCard(
                        branch: branch,
                        onEdit: () => _showEditDialog(branch),
                        onDelete: () => _confirmDelete(branch),
                        onToggleActive: () => _toggleActive(branch),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
            'Loading branches…',
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
              onPressed: () => ref.read(branchesProvider.notifier).loadBranches(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, ThemeData theme, bool noBranchesAtAll) {
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
                Icons.location_city_outlined,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              noBranchesAtAll ? 'No branches yet' : 'No matches found',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              noBranchesAtAll
                  ? 'Create your first branch to get started.'
                  : 'Try adjusting your search terms.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (noBranchesAtAll) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Branch'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
