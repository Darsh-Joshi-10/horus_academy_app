import 'package:flutter/material.dart';
import '../models/branch_model.dart';
import '../repository/branch_repository.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  final _branchRepository = BranchRepository();
  final _searchController = TextEditingController();

  List<Branch> _allBranches = [];
  List<Branch> _filteredBranches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
    _searchController.addListener(_filterBranches);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBranches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final branches = await _branchRepository.getBranches();
      if (!mounted) return;
      setState(() {
        _allBranches = branches;
        _filteredBranches = branches;
        _isLoading = false;
      });
      _filterBranches();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterBranches() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredBranches = _allBranches;
      });
    } else {
      setState(() {
        _filteredBranches = _allBranches.where((b) {
          return b.name.toLowerCase().contains(query) ||
              b.branchCode.toLowerCase().contains(query) ||
              b.city.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  void _showBranchFormDialog([Branch? branch]) {
    final isEditing = branch != null;
    final codeCtrl = TextEditingController(text: branch?.branchCode ?? "");
    final nameCtrl = TextEditingController(text: branch?.name ?? "");
    final addressCtrl = TextEditingController(text: branch?.address ?? "");
    final cityCtrl = TextEditingController(text: branch?.city ?? "");
    final stateCtrl = TextEditingController(text: branch?.state ?? "");
    final phoneCtrl = TextEditingController(text: branch?.phone ?? "");
    final emailCtrl = TextEditingController(text: branch?.email ?? "");
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(isEditing ? "Edit Branch" : "Add New Branch"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: "Branch Code (e.g. B001)"),
                  validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Branch Name"),
                  validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: "Address"),
                  validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: cityCtrl,
                        decoration: const InputDecoration(labelText: "City"),
                        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: stateCtrl,
                        decoration: const InputDecoration(labelText: "State"),
                        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: "Phone (Optional)"),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email (Optional)"),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(dialogCtx);
              final data = {
                "branch_code": codeCtrl.text.trim(),
                "name": nameCtrl.text.trim(),
                "address": addressCtrl.text.trim(),
                "city": cityCtrl.text.trim(),
                "state": stateCtrl.text.trim(),
                "phone": phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                "email": emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
              };

              try {
                if (isEditing) {
                  await _branchRepository.updateBranch(branch.id, data);
                } else {
                  await _branchRepository.createBranch(data);
                }
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(isEditing ? "Branch updated" : "Branch added successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
                _fetchBranches();
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(isEditing ? "Save Changes" : "Create Branch"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Branch branch) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Delete Branch"),
        content: Text("Are you sure you want to delete '${branch.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(dialogCtx);
              try {
                await _branchRepository.deleteBranch(branch.id);
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("Branch deleted"),
                    backgroundColor: Colors.orange,
                  ),
                );
                _fetchBranches();
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Branch Management"),
        actions: [
          IconButton(
            onPressed: _fetchBranches,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBranchFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Add Branch"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search branches by name, code, or city...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _fetchBranches,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      )
                    : _filteredBranches.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.location_city_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  "No branches found",
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchBranches,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _filteredBranches.length,
                              itemBuilder: (context, index) {
                                final branch = _filteredBranches[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.deepPurple.shade100,
                                      child: Text(
                                        branch.branchCode,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.deepPurple.shade900,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      branch.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      "${branch.address}, ${branch.city}, ${branch.state}"
                                      "${branch.phone != null ? '\nPhone: ${branch.phone}' : ''}",
                                    ),
                                    isThreeLine: branch.phone != null,
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          _showBranchFormDialog(branch);
                                        } else if (val == 'delete') {
                                          _confirmDelete(branch);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 18),
                                              SizedBox(width: 8),
                                              Text("Edit"),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red, size: 18),
                                              SizedBox(width: 8),
                                              Text("Delete", style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
