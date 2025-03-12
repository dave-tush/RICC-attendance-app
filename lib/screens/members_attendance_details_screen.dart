import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MembersAttendanceDetailsScreen extends StatelessWidget {
  final String date;
  const MembersAttendanceDetailsScreen({super.key, required this.date});

  Future<List<Map<String, dynamic>>> fetchMembers(String date) async {
    try {
      final db = FirebaseFirestore.instance;
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }
      String uid = user.uid;
      final membersCollection = db.collection('users').doc(uid).collection('attendance').doc(date).collection('members');

      final querySnapshot = await membersCollection.get();

      if (querySnapshot.docs.isEmpty) {
        print("No members present on $date");
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
        future: fetchMembers(date),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No members were present.'));
          }

          final members = snapshot.data!;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(member['name'] ?? 'Unknown'),
                  subtitle: Text(member['gender'] ?? 'No Department'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Count: ${member['attendanceCount'] ?? 0}"),
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

