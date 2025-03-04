import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceDetailsScreen extends StatelessWidget {
  final String date;
  const AttendanceDetailsScreen({super.key, required this.date});

  Future<List<Map<String, dynamic>>> fetchWorkers(String date) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in');
        return [];
      }
      String uid = user.uid;
      final db = FirebaseFirestore.instance;
      final workersCollection = db.collection('users').doc(uid).collection('attendance').doc(date).collection('workers');

      final querySnapshot = await workersCollection.get();

      if (querySnapshot.docs.isEmpty) {
        print("No workers present on $date");
        return [];
      }

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching workers: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance on $date')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchWorkers(date),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No workers were present.'));
          }

          final workers = snapshot.data!;

          return ListView.builder(
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(worker['name'] ?? 'Unknown'),
                  subtitle: Text(worker['schoolDepartment'] ?? 'No Department'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Count: ${worker['attendanceCount'] ?? 0}"),
                      Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

