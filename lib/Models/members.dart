class Members {
  final String name;
  final String level;
  final String gender;
  final String phoneNumber;
  final String dateOfBirth;
  bool isPresent;

  Members({
    required this.name,
    required this.level,
    required this.gender,
    required this.phoneNumber,
    required this.dateOfBirth,
    this.isPresent = false,
  });

  factory Members.fromFirestore(Map<String, dynamic> data, String id) {
    return Members(
      name: data['name'],
      level: data['level'],
      isPresent: data['isPresent'] ?? false,
      gender: data['gender'],
      phoneNumber: data['phoneNumber'],
      dateOfBirth: data['dateOfBirth'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'level': level,
      'isPresent': isPresent,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth
    };
  }
}
