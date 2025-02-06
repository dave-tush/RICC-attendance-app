import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  final String date;
  AttendanceScreen({required this.date});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _getDayOfTheWeek(String date){
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd-MMMM-yyyy').format(parsedDate);
    } catch(e){
      return '$e';
    }
  }
  Future<List<Map<String, dynamic>>> fetchAttendance(String date) async {
    try {
      final db = FirebaseFirestore.instance;
      final attendanceCollection = db.collection('attendance').doc(date).collection('worker');

      final querySnapshot = await attendanceCollection.get();

      if (querySnapshot.docs.isEmpty) {
        print("No attendance records found for $date");
      }

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching attendance: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance on ${widget.date}')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAttendance(widget.date),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No attendance records found.'));
          }

          final workers = snapshot.data!;

          return ListView.builder(
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return ListTile(
                title: Text(worker['name']),
                subtitle: Text(worker['schoolDepartment']),
                trailing: worker['isPresent'] == true
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.cancel, color: Colors.red),
              );
            },
          );
        },
      ),
    );
  }
}
