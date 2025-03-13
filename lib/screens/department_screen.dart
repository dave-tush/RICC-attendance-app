import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/Provider/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DepartmentScreen extends StatelessWidget {
  final String department;
  const DepartmentScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    // Get workers synchronously since data is already loaded
    final workers = provider.getWorkersByDepartment(department);

    return Scaffold(
      appBar: AppBar(
        title: Text(department),
      ),
      body: workers.isEmpty
          ? const Center(child: Text('No workers in this department'))
          : ListView.builder(
        itemCount: workers.length,
        itemBuilder: (context, index) {
          final worker = workers[index];
          final data = worker.data() as Map<String, dynamic>;

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                data['profileImageUrl'] ?? 'https://default-image.com',
              ),
            ),
            title: Text(data['name'] ?? 'No Name'),
            subtitle: Text(data['churchDepartment'] ?? 'No Department'),
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );
  }
}
