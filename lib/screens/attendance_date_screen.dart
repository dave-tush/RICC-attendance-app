import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/screens/members_attendance_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Provider/attendance_provider.dart';
import 'attendance_screen.dart';


class AttendanceDatesScreen extends StatefulWidget {
  @override
  _AttendanceDatesScreenState createState() => _AttendanceDatesScreenState();
}

class _AttendanceDatesScreenState extends State<AttendanceDatesScreen> {
  String _getFormattedDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMMM d, y').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Future<Map<String, dynamic>> fetchAttendanceDates() async {
    try {
      final db = FirebaseFirestore.instance;
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in');
        return {};
      }
      String uid = user.uid;
      final querySnapshot = await db.collection('users').doc(uid).collection('attendance').get();

      if (querySnapshot.docs.isEmpty) {
        print("No attendance records found");
        return {};
      }

      final Map<String, dynamic> attendanceData = {};
      for (final doc in querySnapshot.docs) {
        final date = doc.id.split('T').first;
        final additionalText = doc['additionalText'] as String?; // Fetch additional text
        attendanceData[date] = {
          'formattedDate': _getFormattedDate(date),
          'additionalText': additionalText,
        };
      }

      return attendanceData;
    } catch (e) {
      print("Error fetching attendance dates: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
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
              final dateKey = dates.keys.elementAt(index); // Get the date key
              final dateData = dates[dateKey]; // Get the data for this date
              final formattedDate = dateData['formattedDate']; // Get formatted date
              final additionalText = dateData['additionalText']; // Get additional text

              return ListTile(
                title: Text("${additionalText ?? 'No additional text'} ($formattedDate)"),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceDetailsScreen(date: dateKey),
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



