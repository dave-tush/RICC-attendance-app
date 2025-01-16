class Worker {
  final String id;
  final String name;
  final String position;
  final bool isPresent;

  Worker({
    required this.id,
    required this.name,
    required this.position,
    this.isPresent = false,
  });

  // Convert Firebase document to Worker object
  factory Worker.fromFirestore(Map<String, dynamic> data, String id) {
    return Worker(
      id: id,
      name: data['name'],
      position: data['position'],
      isPresent: data['isPresent'] ?? false,
    );
  }

  // Convert Worker object to Firebase document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'position': position,
      'isPresent': isPresent,
    };
  }
}
