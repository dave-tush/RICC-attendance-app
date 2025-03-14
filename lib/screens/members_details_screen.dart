import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/members.dart';
import '../Provider/attendance_provider.dart';
import '../foundation/color.dart';
import '../widgets/call_to_action_button.dart';
import 'edit_workers_screen.dart';
class MembersDetailScreen extends StatelessWidget {
  final Members members;
  final String documentId;

  const MembersDetailScreen({
    super.key,
    required this.members,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = MyColor();
    final provider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          members.name,
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
                getInitials(members.name),
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
              members.name,
              style: TextStyle(
                fontSize: 24,
                color: colors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              members.whatsAppPhoneNumber,
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
          members.address,
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
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AlertDialog();
              }));
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
        _buildInfoItem('Gender', members.gender, colors),
        _buildInfoItem('Birth Date', members.dateOfBirth, colors),
        _buildInfoItem('First Timer', members.firstTimer, colors),
        _buildInfoItem('Level', members.level, colors),
        _buildInfoItem('whatsApp number', members.whatsAppPhoneNumber, colors),
        _buildInfoItem('Phone Number', members.phoneNumber, colors),
        _buildInfoItem('Address', members.address, colors),
        _buildInfoItem('Present', members.isPresent.toString(), colors),
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

  _showEditDialog(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    final controller = TextEditingController(text: members.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Worker'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
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
        content: Text('Delete ${members.name}?'),
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