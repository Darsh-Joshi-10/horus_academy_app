import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../admin/screens/pending_users_screen.dart';
import '../../branches/screens/branch_list_screen.dart';
import '../models/user.dart';
import '../repository/auth_repository.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User? user;

  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
        _error = _user == null
            ? "Unable to verify your session."
            : null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _user == null
              ? _buildErrorState()
              : _buildSuccessState(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
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

  Widget _buildSuccessState() {
    final user = _user!;

    if (user.status.toUpperCase() == 'PENDING') {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.hourglass_top,
                      size: 72,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Application Under Review',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your account has been submitted and is waiting for admin approval. You can still browse this welcome screen while we review your request.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What you can do now',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.school_outlined, color: Colors.deepPurple),
                title: const Text('Explore Horus Academy'),
                subtitle: const Text('Get familiar with the platform while your account is being reviewed.'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.blue),
                title: const Text('Check your status later'),
                subtitle: const Text('You will be notified once an administrator approves your account.'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout_outlined, color: Colors.grey),
                title: const Text('Sign out anytime'),
                subtitle: const Text('You can return to this screen after logging back in.'),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 72,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Login Successful',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are authenticated and connected to the backend.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Account',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.person_outline,
            label: 'Name',
            value: user.fullName,
          ),
          _InfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          _InfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone,
          ),
          _InfoTile(
            icon: Icons.badge_outlined,
            label: 'Role ID',
            value: user.roleId.toString(),
          ),
          _InfoTile(
            icon: Icons.info_outline,
            label: 'Status',
            value: user.status,
          ),
          _InfoTile(
            icon: Icons.verified_user_outlined,
            label: 'Account Active',
            value: user.isActive ? 'Yes' : 'No',
          ),
          if (user.roleId == 1) ...[
            const SizedBox(height: 24),
            Text(
              'Admin Operations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PendingUsersScreen(),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: const [
                            Icon(Icons.pending_actions, size: 36, color: Colors.amber),
                            SizedBox(height: 8),
                            Text(
                              "Pending Users",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BranchListScreen(),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.deepPurple.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: const [
                            Icon(Icons.location_city, size: 36, color: Colors.deepPurple),
                            SizedBox(height: 8),
                            Text(
                              "Branches",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              'Note: $_error',
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
