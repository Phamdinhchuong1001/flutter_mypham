class UserInfo {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String? avatar;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.avatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'avatar': avatar,
    };
  }
}
