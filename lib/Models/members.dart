class Members {
  final String name;
  final String level;
  final String gender;
  final String phoneNumber;
  final String dateOfBirth;
  final String address;
  final String whatsAppPhoneNumber;
  bool isPresent;
  final String firstTimer;
  final String type;

  Members({
    required this.name,
    required this.level,
    required this.gender,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.firstTimer,
    required this.address,
    required this.whatsAppPhoneNumber,
    required this.type,
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
        firstTimer: data['firstTimer'],
        type: data['type'],
        address: data['address'],
        whatsAppPhoneNumber: data['whatsAppPhoneNumber']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'level': level,
      'isPresent': isPresent,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'firstTimer': firstTimer,
      'type': type,
      'address': address,
      'whatsAppPhoneNumber': whatsAppPhoneNumber
    };
  }
}
