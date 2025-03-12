import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/Provider/attendance_provider.dart';
import 'package:first_project/foundation/color.dart';
import 'package:first_project/widgets/call_to_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/workers.dart';

class WorkerDetailsScreen extends StatelessWidget {
  final String worker;
  final String churchDepartment;
  final String phoneNumber;
  final String gender;
  final String level;
  final bool isPresent;
  final String id;
  final Timestamp timeStamp;
  final String documentId;
  final int attendanceCount;
  final String birthDate;
  final String email;

  const WorkerDetailsScreen({
    super.key,
    required this.worker,
    required this.churchDepartment,
    required this.phoneNumber,
    required this.level,
    required this.gender,
    required this.isPresent,
    required this.id,
    required this.documentId,
    required this.attendanceCount,
    required this.birthDate,
    required this.timeStamp,
    required this.email
  });

  @override
  Widget build(BuildContext context) {
    final colors = MyColor();
    final provider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          worker,
          style: TextStyle(
            color: colors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        //  actions: [
        //  IconButton(
        //    onPressed: () {
        //    _confirmDelete(context, provider, documentId, worker);
        // },
        // icon: Icon(Icons.delete))
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 350,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50.0,
                    vertical: 50,
                  ),
                  child: Column(
                    children: [
                      provider.profileImageUrl != null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(provider.profileImageUrl!),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: colors.primaryColor,
                              child: Text(
                                getInitials(worker),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colors.mainColor,
                                ),
                              ),
                            ),
                      Text(
                        worker,
                        style: TextStyle(
                          fontSize: 24,
                          color: colors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          color: colors.primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Attendance',
                        style: TextStyle(
                          fontSize: 18,
                          color: colors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(attendanceCount.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: colors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ))
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 350,
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 50.0, left: 30, right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn("Gender", gender),
                          SizedBox(
                            width: 150,
                          ),
                          _buildInfoColumn("Birth date", birthDate),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn(
                              "Church Department", churchDepartment),
                          SizedBox(
                            width: 48,
                          ),
                          _buildInfoColumn(
                              "School Department", churchDepartment),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn("Level", level),
                          SizedBox(
                            width: 150,
                          ),
                          _buildInfoColumn("Arrival time", ""), // Empty for now
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInfoColumn("Present", isPresent.toString()),
                      const SizedBox(height: 10),
                      button(context, 'Edit', () {}),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    final colors = MyColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.primaryColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.primaryColor,
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, AttendanceProvider provider,
      Worker worker, int index) {
    final nameController = TextEditingController(text: worker.name);
    final positionController =
        TextEditingController(text: worker.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Worker'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Position'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Position'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Position'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Position'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Position'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Position'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedWorker = Worker(
                  name: nameController.text,
                  id: worker.id,
                  isPresent: worker.isPresent,
                  timestamp: Timestamp.now(),
                  phoneNumber: '1234',
                  level: '',
                  churchDepartment: '',
                  gender: '',
                  address: '',
                  dateOfBirth: '',
                  attendanceCount: 0, email: '',
                  type: 'workers'
                );
                provider.updateWorkers(index, updatedWorker);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, AttendanceProvider provider,
      String documentId, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete $name?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await provider.deleteWorker(documentId);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Worker deleted successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

String getInitials(String? name) {
  if (name == null || name.isEmpty) return "?";
  List<String> nameParts = name.trim().split(" ");
  if (nameParts.length >= 2) {
    return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
  } else {
    return nameParts[0].substring(0, 2).toUpperCase();
  }
}
