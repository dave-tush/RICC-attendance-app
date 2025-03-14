import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/Provider/attendance_provider.dart';
import 'package:first_project/foundation/color.dart';
import 'package:first_project/screens/edit_workers_screen.dart';
import 'package:first_project/widgets/call_to_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/workers.dart';

class WorkerDetailsScreen extends StatelessWidget {
  final Worker worker;
  final String documentId;

  const WorkerDetailsScreen({
    super.key,
    required this.worker,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = MyColor();
    final provider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          worker.name,
          style: TextStyle(
            color: colors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(context, provider),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileSection(colors, provider),
              const SizedBox(height: 20),
              _buildInfoSection(colors, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(MyColor colors, AttendanceProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: colors.primaryColor,
              backgroundImage: provider.profileImageUrl != null
                  ? NetworkImage(provider.profileImageUrl!)
                  : null,
              child: provider.profileImageUrl == null
                  ? Text(
                      getInitials(worker.name),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.mainColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              worker.name,
              style: TextStyle(
                fontSize: 24,
                color: colors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              worker.whatsAppNumber,
              style: TextStyle(color: colors.primaryColor),
            ),
            const SizedBox(height: 20),
            _buildAttendanceCount(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCount(MyColor colors) {
    return Column(
      children: [
        Text(
          'Attendance',
          style: TextStyle(
            fontSize: 18,
            color: colors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          worker.attendanceCount.toString(),
          style: TextStyle(
            fontSize: 18,
            color: colors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(MyColor colors, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoGrid(colors),
            const SizedBox(height: 20),
            button(context, 'Edit Profile', () {
             // showEditDialog(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(MyColor colors) {
    const spacing = 0.0;
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 8,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      children: [
        _buildInfoItem('Gender', worker.gender, colors),
        _buildInfoItem('Birth Date', worker.dateOfBirth, colors),
        _buildInfoItem('Church Department', worker.churchDepartment, colors),
        _buildInfoItem('Level', worker.level, colors),
        _buildInfoItem('whatsApp number', worker.whatsAppNumber, colors),
        _buildInfoItem('Phone Number', worker.phoneNumber, colors),
        _buildInfoItem('Address', worker.address, colors),
        _buildInfoItem('Present', worker.isPresent.toString(), colors),
      ],
    );
  }

  Widget _buildInfoItem(String title, String value, MyColor colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.primaryColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: colors.primaryColor,
          ),
        ),
      ],
    );
  }

  void showEditDialog(BuildContext context, DocumentSnapshot document, String collectionType,AttendanceProvider provider) {
    final nameController = TextEditingController(text: document['name']);
    final phoneNumberController = TextEditingController(text: document['phoneNumber']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedName = nameController.text.trim();
              final updatedPhoneNumber = phoneNumberController.text.trim();
              final FirebaseFirestore _db = FirebaseFirestore.instance;
              if (updatedName.isNotEmpty && updatedPhoneNumber.isNotEmpty) {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;
                  String uid = user.uid;

                  final updatedData = {
                    'name': updatedName,
                    'phoneNumber': updatedPhoneNumber,
                  };

                  // Update the specific collection (workers or members)
                  await _db
                      .collection('users')
                      .doc(uid)
                      .collection(collectionType)
                      .doc(document.id)
                      .update(updatedData);

                  // Also update the 'all' collection
                  await _db
                      .collection('users')
                      .doc(uid)
                      .collection('all')
                      .doc(document.id)
                      .update(updatedData);

                  Navigator.of(context).pop();
                 provider.fetchData(); // Refresh the data
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Details updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and phone number cannot be empty')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AttendanceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Delete ${worker.name}?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await provider.deleteWorker(documentId);
              Navigator.of(context)
                ..pop()
                ..pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Worker deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

String getInitials(String name) {
  if (name.isEmpty) return "??";
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
  return name.substring(0, 2);
}
