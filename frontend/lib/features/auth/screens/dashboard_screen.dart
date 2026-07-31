import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/storage_service.dart';
import '../../admin/widgets/admin_dashboard_body.dart';
import '../../student/widgets/student_dashboard_body.dart';
import '../../teacher/widgets/teacher_dashboard_body.dart';
import '../models/user.dart';
import '../repository/auth_repository.dart';
import 'login_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final User? user;

  const DashboardScreen({super.key, this.user});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _authRepository = AuthRepository();

  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (widget.user != null) {
      setState(() {
        _user = widget.user;
        _isLoading = false;
      });
      return;
    }

    final cachedUser = await StorageService.getUser();

    if (cachedUser != null) {
      setState(() {
        _user = cachedUser;
        _isLoading = false;
      });
    }

    try {
      final user = await _authRepository.getCurrentUser();
      await StorageService.saveUser(user);

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
        _error = null;
      });
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = _user == null ? 'Unable to verify your session.' : null;
      });
    }
  }

  Future<void> _logout() async {
    await StorageService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _dashboardTitle(User user) {
    if (user.isAdmin) return 'Admin Dashboard';
    if (user.isTeacher) return 'Teacher Dashboard';
    if (user.isStudent) return 'Student Dashboard';
    return 'Dashboard';
  }

  Widget _buildRoleDashboard(User user) {
    if (user.isAdmin) {
      return AdminDashboardBody(user: user);
    }
    if (user.isTeacher) {
      return TeacherDashboardBody(user: user);
    }
    if (user.isStudent) {
      return StudentDashboardBody(user: user);
    }

    return StudentDashboardBody(user: user);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _user != null ? _dashboardTitle(_user!) : 'Dashboard',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your dashboard…',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : _error != null && _user == null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadUser,
                  child: _buildRoleDashboard(_user!),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
