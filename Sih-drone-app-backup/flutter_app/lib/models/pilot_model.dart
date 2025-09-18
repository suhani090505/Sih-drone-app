class Pilot {
  final String id;
  final String name;
  final String licenseId;
  final DateTime createdAt;

  const Pilot({
    required this.id,
    required this.name,
    required this.licenseId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'licenseId': licenseId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Pilot.fromJson(Map<String, dynamic> json) {
    return Pilot(
      id: json['id'],
      name: json['name'],
      licenseId: json['licenseId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}