class RoleModel {
  final int id;
  final String name;

  RoleModel({
    required this.id,
    required this.name,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
    );
  }
}


class AdminUserModel {
  final String id;

  final String firstName;
  final String lastName;

  final String email;
  final String phone;

  final String status;

  final RoleModel role;

  final DateTime? approvedAt;


  AdminUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.status,
    required this.role,
    this.approvedAt,
  });


  factory AdminUserModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminUserModel(

      id: json['id'],

      firstName: json['first_name'],

      lastName: json['last_name'],

      email: json['email'],

      phone: json['phone'],

      status: json['status'],

      role: RoleModel.fromJson(
        json['role'],
      ),

      approvedAt: json['approved_at'] != null
          ? DateTime.parse(
              json['approved_at'],
            )
          : null,
    );
  }
}