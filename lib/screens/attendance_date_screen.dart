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
  String _getDayOfTheWeek(String date){
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd-MMMM-yyyy').format(parsedDate);
    } catch(e){
      return '$e';
    }
  }
  Future<List<String>> fetchAttendance() async {
    try {
      final db = FirebaseFirestore.instance;
      final querySnapshot = await db.collection('attendance').get();
      print(querySnapshot.docs.length);
      if (querySnapshot.docs.isEmpty) {
        print("No attendance records found for today");
        return [];
      }
      final dates = <String>[];
      for (final doc in querySnapshot.docs) {
        final workerSnapShot = await doc.reference.collection('worker').get();
        if (workerSnapShot.docs.isNotEmpty) {
          dates.add(doc.id);
        }
      }
      dates.sort((a, b) => b.compareTo(a)); // Sort dates descending
      return dates;
    } catch (e) {
      print("Error fetching attendance: $e");
      return [];
    }
  }

  late Future<List<String>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = fetchAttendance();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Dates')),
      body: FutureBuilder<List<String>>(
        future: _attendanceFuture,
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
              final dateOfTheWeek = _getDayOfTheWeek(date);
              return ListTile(
                title: Text(dateOfTheWeek),
                onTap: () {
                  // Navigate to attendance details for that date
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceScreen(date: dateOfTheWeek),
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
