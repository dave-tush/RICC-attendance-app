import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'members_attendance_details_screen.dart';

class MembersAttendanceDateScreen extends StatefulWidget {
  const MembersAttendanceDateScreen({super.key});

  @override
  _MembersAttendanceDatesScreenState createState() => _MembersAttendanceDatesScreenState();
}

class _MembersAttendanceDatesScreenState extends State<MembersAttendanceDateScreen> {


  String _getFormattedDate(String date){
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMMM d, y').format(parsedDate);
    } catch(e){
      return date;
    }
  }
  Future<Map<String, dynamic>> fetchAttendanceDates() async {
    try {
      final db = FirebaseFirestore.instance;
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {};
      }
      String uid = user.uid;
      final querySnapshot = await db.collection('users').doc(uid).collection('attendance').get();

      if (querySnapshot.docs.isEmpty) {
        print("No attendance records found");
        return {};
      }
      final Map<String, dynamic> attendanceDate = {};
      for (final doc in querySnapshot.docs) {
        final date = doc.id.split('T').first;
        final additionalText = doc ['additionalText'] as String?;
        attendanceDate[date] = {
          'formattedDate': _getFormattedDate(date),
          'additionalText' : additionalText,
        };
      }
      return attendanceDate;
    } catch (e) {
      print("Error fetching attendance dates: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Dates')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchAttendanceDates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No attendance records found.'));
          }

          final dates = snapshot.data!;

          return ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final dateKey = dates.keys.elementAt(index);
              final dateData = dates[dateKey];

              final date = dates[index];
              final formattedDate = dateData['formattedDate'];
              final additionalText = dateData['additionalText'];

              return ListTile(
                title: Text("${additionalText ?? 'No additional text'} ($formattedDate)"),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MembersAttendanceDetailsScreen(date: dateKey),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
