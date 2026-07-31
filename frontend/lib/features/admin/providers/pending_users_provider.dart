import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/user.dart';
import '../repository/admin_repository.dart';


final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});


final pendingUsersProvider = StateNotifierProvider<
    PendingUsersNotifier,
    AsyncValue<List<User>>>((ref) {

  return PendingUsersNotifier(
    ref.read(adminRepositoryProvider),
  );

});



class PendingUsersNotifier
    extends StateNotifier<AsyncValue<List<User>>> {


  final AdminRepository repository;


  PendingUsersNotifier(
    this.repository,
  ) : super(
        const AsyncValue.loading(),
      ) {

    loadPendingUsers();

  }



  Future<void> loadPendingUsers() async {

    try {

      state = const AsyncValue.loading();


      final users = await repository.getPendingUsers();


      state = AsyncValue.data(
        users,
      );


    } catch (error, stackTrace) {

      state = AsyncValue.error(
        error,
        stackTrace,
      );

    }

  }



  Future<void> approveUser(
    String userId,
    int roleId, {
    String? branchId,
  }) async {

    await repository.approveUser(
      userId,
      roleId: roleId,
      branchId: branchId,
    );


    await loadPendingUsers();

  }



  Future<void> rejectUser(
    String userId,
  ) async {

    await repository.rejectUser(
      userId,
    );


    await loadPendingUsers();

  }



  Future<void> suspendUser(
    String userId,
  ) async {

    await repository.suspendUser(
      userId,
    );


    await loadPendingUsers();

  }

}