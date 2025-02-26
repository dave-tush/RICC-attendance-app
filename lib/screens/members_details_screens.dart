import 'package:first_project/Provider/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/members.dart';

class MemberDetailsScreen extends StatelessWidget {
  final String name;
  final String id;
  final String level;
  final bool isPresent;

  const MemberDetailsScreen(
      {super.key,
      required this.name,
      required this.id,
      required this.level,
      required this.isPresent,
      });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
              onPressed: () {

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
              'Name: ${name}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'ID: ${id}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Role: ${level}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Present: ${isPresent ? 'Yes' : 'No'}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
