class Role {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  const Role({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }
}
