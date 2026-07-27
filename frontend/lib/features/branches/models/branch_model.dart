class Branch {
  final String id;
  final String branchCode;
  final String name;
  final String address;
  final String city;
  final String state;
  final String? phone;
  final String? email;
  final bool isActive;

  Branch({
    required this.id,
    required this.branchCode,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    this.phone,
    this.email,
    required this.isActive,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as String,
      branchCode: json['branch_code'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_code': branchCode,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'phone': phone,
      'email': email,
      'is_active': isActive,
    };
  }
}
