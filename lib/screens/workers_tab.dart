import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/screens/absent_worker.dart';
import 'package:first_project/screens/attendance_date_screen.dart';
import 'package:first_project/screens/attendance_screen.dart';
import 'package:first_project/screens/workers_details_screen.dart';
import 'package:first_project/widgets/high_light_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/attendance_provider.dart';
import 'package:intl/intl.dart';

class WorkersTab extends StatefulWidget {
  const WorkersTab({super.key});

  @override
  State<WorkersTab> createState() => _WorkersTabState();
}

class _WorkersTabState extends State<WorkersTab> {
  @override
  void initState() {
    super.initState();

    // Fetch data automatically on app start
    Provider.of<AttendanceProvider>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Workers',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              provider.setSearchQuery(value);
            },
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            await provider.saveWorker();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance saved for today!')),
            );
          },
          child: const Text('Save workers Attendance'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceDatesScreen(),
              ),
            );
          },
          child: const Text('Show attendance'),
        ),
        ElevatedButton(
          onPressed: () {
            provider.pickExcelFile();
          },
          child: Text("Import Excel"),
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () async {
            await provider.notifyAbsentMembers();
            await ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('WhatsApp notifications sent!')),
            );
          },
        ),
        StreamBuilder<QuerySnapshot>(
            stream: provider.getDataStream(),
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapShot.hasError) {
                return Center(
                  child: Text('Error: ${snapShot.hasError}'),
                );
              } else if (!snapShot.hasData || snapShot.data!.docs.isEmpty) {
                return Center(
                  child: Text('No Worker Added yet'),
                );
              } else {
                provider.setWorkers(snapShot.data!.docs);
                final filteredWorkers = provider.filteredWorkers;
                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredWorkers.length,
                    itemBuilder: (context, index) {
                      final query = provider.searchQuery;
                      DocumentSnapshot document = filteredWorkers[index];
                      String documentId = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String noteText = data['name'];
                      String schoolDepartment = data['schoolDepartment'];
                      bool isPresent = data['isPresent'] ?? false;
                      String churchDepartment = data['churchDepartment'];
                      String level = data['level'];
                      String gender = data['gender'];
                      Timestamp timeStamp = data['timeStamp'];
                      return ListTile(
                        leading: Checkbox(
                            value: isPresent,
                            onChanged: (value) {
                              provider.toggleWorkersAttendance(
                                  documentId, isPresent);
                            }),
                        title: RichText(
                            text: highlightText(
                                noteText,
                                query,
                                TextStyle(color: Colors.black),
                                TextStyle(color: Colors.blue))),
                        subtitle: Text(schoolDepartment),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WorkerDetailsScreen(
                                worker: noteText,
                                schoolDepartment: schoolDepartment,
                                phoneNumber: '1234',
                                churchDepartment: churchDepartment,
                                level: level,
                                gender: gender,
                                isPresent: isPresent,
                                timeStamp: timeStamp,
                                id: '',
                                documentId: documentId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }
            })
      ],
    );
  }
}
