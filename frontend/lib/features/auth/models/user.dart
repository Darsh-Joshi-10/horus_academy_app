class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int roleId;
  final String? roleName;
  final String? branchId;
  final String status;
  final bool emailVerified;
  final bool phoneVerified;
  final bool isActive;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.roleId,
    this.roleName,
    this.branchId,
    required this.status,
    required this.emailVerified,
    required this.phoneVerified,
    required this.isActive,
  });

  String get fullName => "$firstName $lastName";

  String get displayRole {
    if (roleName != null && roleName!.isNotEmpty) return roleName!;
    switch (roleId) {
      case 1:
        return 'Admin';
      case 2:
        return 'Teacher';
      case 3:
        return 'Student';
      default:
        return 'User';
    }
  }

  bool get isAdmin =>
      roleId == 1 || (roleName?.toLowerCase().contains('admin') ?? false);

  bool get isTeacher =>
      roleId == 2 || (roleName?.toLowerCase().contains('teacher') ?? false);

  bool get isStudent =>
      roleId == 3 || (roleName?.toLowerCase().contains('student') ?? false);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] as String,
      firstName: json["first_name"] as String,
      lastName: json["last_name"] as String,
      email: json["email"] as String,
      phone: json["phone"] as String,
      roleId: json["role_id"] as int,
      roleName: json["role_name"] as String?,
      branchId: json["branch_id"] as String?,
      status: json["status"] as String,
      emailVerified: json["email_verified"] as bool,
      phoneVerified: json["phone_verified"] as bool,
      isActive: json["is_active"] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "role_id": roleId,
      "role_name": roleName,
      "branch_id": branchId,
      "status": status,
      "email_verified": emailVerified,
      "phone_verified": phoneVerified,
      "is_active": isActive,
    };
  }
}
