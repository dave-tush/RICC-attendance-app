import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/attendance_provider.dart';
import '../foundation/color.dart';

class DepartmentsPage extends StatelessWidget {
  const DepartmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final colors = MyColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: provider.getAllDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No departments found.'));
          } else {
            final departments = <String, List<DocumentSnapshot>>{};
            for (final doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final department = data['churchDepartment'] ?? data['schoolDepartment'];
              if (!departments.containsKey(department)) {
                departments[department] = [];
              }
              departments[department]!.add(doc);
            }

            return ListView.builder(
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final department = departments.keys.elementAt(index);
                final members = departments[department]!;
                return ExpansionTile(
                  title: Text(department),
                  children: members.map((member) {
                    final data = member.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name']),
                      subtitle: Text(data['phoneNumber']),
                    );
                  }).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }
}