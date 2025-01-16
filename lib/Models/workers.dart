class Worker {
  final String name;
  final String id;
  final String department;
  bool isPresent;

  Worker({
    required this.name,
    required this.id,
    required this.department,
    this.isPresent = false,
  });

  factory Worker.fromFirestore(Map<String, dynamic> data, String id) {
    return Worker(
        name: data['name'],
        id: id,
        department: data['department'],
        isPresent: data['isPresent'] ?? false);
  }
  Map<String, dynamic> toFirestore (){
    return {
      'name': name,
      'department': department,
      'isPresent': isPresent
    };
  }
}
