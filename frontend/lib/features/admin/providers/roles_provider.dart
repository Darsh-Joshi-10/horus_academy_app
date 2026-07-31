import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/role_model.dart';
import 'pending_users_provider.dart';

final rolesProvider = FutureProvider<List<Role>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getRoles();
});
