class Members {
  final String name;
  final String id;
  final String level;
  final String gender;
  bool isPresent;

  Members({
    required this.name,
    required this.id,
    required this.level,
    required this.gender,
    this.isPresent = false,
  });

  factory Members.fromFirestore(Map<String, dynamic> data, String id) {
    return Members(
        name: data['name'],
        id: id,
        level: data['level'],
        isPresent: data['isPresent'] ?? false,
        gender: data['gender']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'level': level,
      'isPresent': isPresent,
      'gender': gender,
    };
  }
}
