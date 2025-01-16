class Members {
  final String name;
  final String id;
  final String role;
  bool isPresent;

  Members({
    required this.name,
    required this.id,
    required  this.role,
     this.isPresent = false,
  });

  factory Members.fromFirestore(Map<String, dynamic> data, String id){
    return Members(name: data['name'], id: id, role: data['role'], isPresent: data['isPresent'] ?? false);
  }

  Map<String, dynamic> toFirestore(){
    return {
      'name': name,
      'role' : role,
      'isPresent': isPresent,
    };
  }
}
