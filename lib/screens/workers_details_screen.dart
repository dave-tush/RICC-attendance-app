import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/Provider/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/workers.dart';

class WorkerDetailsScreen extends StatelessWidget {
  final String worker;
  final String churchDepartment;
  final String phoneNumber;
  final String gender;
  final String level;
  final String schoolDepartment;
  final bool isPresent;
  final String id;
  final Timestamp timeStamp;
  final String documentId;

  const WorkerDetailsScreen({
    super.key,
    required this.worker,
    required this.churchDepartment,
    required this.phoneNumber,
    required this.schoolDepartment,
    required this.level,
    required this.gender,
    required this.isPresent,
    required this.id,
    required this.timeStamp, required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(worker),
        actions: [
          IconButton(
              onPressed: () {
                _confirmDelete(context, provider, documentId,worker);
              },
              icon: Icon(Icons.delete))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $worker',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'church Department: $churchDepartment',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'level: $level',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'gender: $gender',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'school Department: $schoolDepartment',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'time: $timeStamp',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'id: $id',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Present: $isPresent',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // _showEditDialog(context, provider, worker, index);
              },
              child: Text("Edit"),
            )
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AttendanceProvider provider,
      Worker worker, int index) {
    final nameController = TextEditingController(text: worker.name);
    final positionController =
        TextEditingController(text: worker.schoolDepartment);
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
                  schoolDepartment: '',
                  churchDepartment: '',
                  gender: '',
                  address: '',
                  dateOfBirth: ''
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
  void _confirmDelete(BuildContext context, AttendanceProvider provider, String documentId, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:  Text('Are you sure you want to delete $name?'),
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
