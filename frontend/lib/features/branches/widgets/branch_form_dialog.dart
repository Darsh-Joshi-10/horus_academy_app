import 'package:flutter/material.dart';

import '../models/branch_model.dart';

class BranchFormDialog extends StatefulWidget {
  final Branch? branch;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  const BranchFormDialog({
    super.key,
    this.branch,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    Branch? branch,
    required Future<void> Function(Map<String, dynamic> data) onSubmit,
  }) {
    return showDialog(
      context: context,
      builder: (_) => BranchFormDialog(branch: branch, onSubmit: onSubmit),
    );
  }

  @override
  State<BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends State<BranchFormDialog> {
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _isActive = true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.branch != null;

  @override
  void initState() {
    super.initState();
    final branch = widget.branch;
    _codeCtrl = TextEditingController(text: branch?.branchCode ?? '');
    _nameCtrl = TextEditingController(text: branch?.name ?? '');
    _addressCtrl = TextEditingController(text: branch?.address ?? '');
    _cityCtrl = TextEditingController(text: branch?.city ?? '');
    _stateCtrl = TextEditingController(text: branch?.state ?? '');
    _phoneCtrl = TextEditingController(text: branch?.phone ?? '');
    _emailCtrl = TextEditingController(text: branch?.email ?? '');
    _isActive = branch?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'branch_code': _codeCtrl.text.trim(),
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
    };

    if (_isEditing) {
      data['is_active'] = _isActive;
    }

    try {
      await widget.onSubmit(data);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _isEditing ? 'Edit Branch' : 'Add New Branch',
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Branch Code',
                  hintText: 'e.g. B001',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Branch code is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Branch Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Branch name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(labelText: 'City'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _stateCtrl,
                      decoration: const InputDecoration(labelText: 'State'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email (optional)'),
                keyboardType: TextInputType.emailAddress,
              ),
              if (_isEditing) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  subtitle: Text(
                    _isActive
                        ? 'Branch is visible and accepting users'
                        : 'Branch is hidden from registration',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(_isEditing ? 'Save Changes' : 'Create Branch'),
        ),
      ],
    );
  }
}
