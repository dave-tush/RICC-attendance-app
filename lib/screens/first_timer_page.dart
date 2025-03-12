import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/attendance_provider.dart';
import '../foundation/color.dart';

class FirstTimersPage extends StatelessWidget {
  const FirstTimersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final colors = MyColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('First Timers'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: provider.getMemberDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No first timers found.'));
          } else {
            final firstTimers = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['firstTimer'] == 'Yes';
            }).toList();

            return ListView.builder(
              itemCount: firstTimers.length,
              itemBuilder: (context, index) {
                final member = firstTimers[index];
                final data = member.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['name']),
                  subtitle: Text(data['phoneNumber']),
                  trailing: Text(data['firstTimer']),
                );
              },
            );
          }
        },
      ),
    );
  }
}