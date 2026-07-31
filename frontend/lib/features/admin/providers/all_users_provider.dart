import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/user.dart';
import '../repository/admin_repository.dart';
import 'pending_users_provider.dart';

final allUsersProvider =
    StateNotifierProvider<AllUsersNotifier, AsyncValue<List<User>>>((ref) {
  return AllUsersNotifier(ref.read(adminRepositoryProvider));
});

class AllUsersNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final AdminRepository repository;

  AllUsersNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadAllUsers();
  }

  Future<void> loadAllUsers() async {
    try {
      state = const AsyncValue.loading();
      final users = await repository.getAllUsers();
      state = AsyncValue.data(users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> suspendUser(String userId) async {
    await repository.suspendUser(userId);
    await loadAllUsers();
  }
}
