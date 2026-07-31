import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/branch_model.dart';
import '../repository/branch_repository.dart';

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return BranchRepository();
});

final branchesProvider =
    StateNotifierProvider<BranchesNotifier, AsyncValue<List<Branch>>>((ref) {
  return BranchesNotifier(ref.read(branchRepositoryProvider));
});

final activeBranchesProvider = FutureProvider<List<Branch>>((ref) async {
  final repository = ref.watch(branchRepositoryProvider);
  return repository.getBranches(activeOnly: true);
});

class BranchesNotifier extends StateNotifier<AsyncValue<List<Branch>>> {
  final BranchRepository repository;

  BranchesNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadBranches();
  }

  Future<void> loadBranches() async {
    try {
      state = const AsyncValue.loading();
      final branches = await repository.getBranches();
      state = AsyncValue.data(branches);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Branch> createBranch(Map<String, dynamic> data) async {
    final branch = await repository.createBranch(data);
    await loadBranches();
    return branch;
  }

  Future<Branch> updateBranch(String branchId, Map<String, dynamic> data) async {
    final branch = await repository.updateBranch(branchId, data);
    await loadBranches();
    return branch;
  }

  Future<void> deleteBranch(String branchId) async {
    await repository.deleteBranch(branchId);
    await loadBranches();
  }

  Future<void> toggleActive(Branch branch) async {
    await repository.updateBranch(branch.id, {'is_active': !branch.isActive});
    await loadBranches();
  }
}
