class Address {
  final String addressId;
  final String addressName;
  final double latitude;
  final double longitude;

  Address({
    required this.addressId,
    required this.addressName,
    required this.latitude,
    required this.longitude,
  });

  // Dùng cho JSON từ API (MySQL)
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['addressId'].toString(),
      addressName: json['addressName'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'addressName': addressName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
