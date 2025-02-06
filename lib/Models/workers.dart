import 'package:cloud_firestore/cloud_firestore.dart';

class Worker {
  final String id;
  final String name;
  final String phoneNumber;
  final String level;
  final String gender;
  final String churchDepartment;
  final String address;
  final String schoolDepartment;
  final String dateOfBirth;
  bool isPresent;
  final Timestamp timestamp;

  Worker(
      {required this.name,
      required this.id,
      this.isPresent = false,
      required this.timestamp,
      required this.phoneNumber,
      required this.level,
      required this.schoolDepartment,
      required this.churchDepartment,
      required this.gender,
      required this.address,
        required this.dateOfBirth,
      });

  factory Worker.fromFirestore(Map<String, dynamic> data, String id) {
    return Worker(
      name: data['name'],
      id: id,
      schoolDepartment: data['SchoolDepartment'],
      isPresent: data['isPresent'] ?? false,
      timestamp: data['timeStamp'],
      churchDepartment: data['churchDepartment'],
      phoneNumber: data['phoneNumber'],
      level: data['level'],
      gender: data['gender'],
      address: data['address'],
      dateOfBirth: data['dateOfBirth']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'schoolDepartment': schoolDepartment,
      'churchDepartment': churchDepartment,
      'phoneNumber': phoneNumber,
      'level': level,
      'gender': gender,
      'address': address,
      'isPresent': isPresent,
      'timeStamp': timestamp,
      'dateOfBirth': dateOfBirth,
    };
  }
}
