import 'package:cloud_firestore/cloud_firestore.dart';

class Worker {
  final String id;
  final String name;
  final String phoneNumber;
  final String level;
  final String gender;
  final String churchDepartment;
  final String address;
  final String dateOfBirth;
  final int attendanceCount;
  final String email;
  final String type;
  bool isPresent;
  final Timestamp timestamp;

  Worker(
      {required this.name,
      required this.id,
      this.isPresent = false,
      required this.timestamp,
      required this.phoneNumber,
      required this.level,
      required this.churchDepartment,
        required this.email,
      required this.gender,
      required this.address,
        required this.dateOfBirth,
        required this.attendanceCount,
        required this.type
      });

  factory Worker.fromFirestore(Map<String, dynamic> data, String id) {
    return Worker(
      name: data['name'] as String? ?? "unknown",
      id: id ?? 'N/A',
      isPresent: data['isPresent'] ?? false,
      timestamp: data['timeStamp'] ?? "N/A",
      churchDepartment: data['churchDepartment'] ?? "N/A",
      phoneNumber: data['phoneNumber'] ?? "N/A",
      level: data['level'] ?? "N/A",
      gender: data['gender']?? "N/A",
      address: data['address']?? "N/A",
      dateOfBirth: data['dateOfBirth']?? "N/A",
        attendanceCount: data['attendanceCount'] ?? 0,
      email: data['email'] ?? "N/A",
      type: data['type']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'churchDepartment': churchDepartment,
      'phoneNumber': phoneNumber,
      'level': level,
      'gender': gender,
      'address': address,
      'isPresent': isPresent,
      'timeStamp': timestamp,
      'dateOfBirth': dateOfBirth,
      'attendanceCount': attendanceCount,
      'email': email,
      'type': type
    };
  }
}
