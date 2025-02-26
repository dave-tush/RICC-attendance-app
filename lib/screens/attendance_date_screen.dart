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


  String _getFormattedDate(String date){
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMMM d, y').format(parsedDate);
    } catch(e){
      return date;
    }
  }
  Future<List<String>> fetchAttendanceDates() async {
    try {
      final db = FirebaseFirestore.instance;
      final querySnapshot = await db.collection('attendance').get();

      if (querySnapshot.docs.isEmpty) {
        print("No attendance records found");
        return [];
      }

      final dates = querySnapshot.docs.map((doc) => doc.id.split('T').first).toList();
      dates.sort((a, b) => b.compareTo(a)); // Sort dates in descending order
      return dates;
    } catch (e) {
      print("Error fetching attendance dates: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Dates')),
      body: FutureBuilder<List<String>>(
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
              final date = dates[index];
              final formattedDate = _getFormattedDate(dates[index]);
              return ListTile(
                title: Text(formattedDate),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceDetailsScreen(date: date),
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



