
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/attendance_provider.dart';

class AbsentWorkersScreen extends StatelessWidget {
  final String date; // yyyy-MM-dd

  const AbsentWorkersScreen({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Absent Workers for $date'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: provider.getAbsentWorker(date),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No absent workers found.'));
          } else {
            final absentWorkers = snapshot.data!;

            return ListView.builder(
              itemCount: absentWorkers.length,
              itemBuilder: (context, index) {
                final worker = absentWorkers[index];
                return ListTile(
                  title: Text(worker['worker'] ?? 'Unknown'),
                  subtitle: Text(worker['churchDepartment'] ?? 'No Department'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
