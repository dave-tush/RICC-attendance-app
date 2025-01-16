import 'package:first_project/Provider/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/members.dart';

class MemberDetailsScreen extends StatelessWidget {
  final Members member;

  const MemberDetailsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        actions: [
          IconButton(onPressed: (){
            provider.deleteMembers(member);
            Navigator.pop(context);
          }, icon: Icon(Icons.delete))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${member.name}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'ID: ${member.id}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Role: ${member.role}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Present: ${member.isPresent ? 'Yes' : 'No'}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
