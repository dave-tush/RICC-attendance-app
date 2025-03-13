import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/screens/attendance_date_screen.dart';
import 'package:first_project/screens/workers_details_screen.dart';
import 'package:first_project/widgets/high_light_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/workers.dart';
import '../Provider/attendance_provider.dart';

import '../foundation/color.dart';
import '../widgets/call_to_action_button.dart';
import 'department_List.dart';

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
    Future.microtask(() {
      Provider.of<AttendanceProvider>(context, listen: false).fetchData();
    });
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
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            button(context, "Save workers Attendance", () async {
              final textDateController = TextEditingController();
              String? additionalText = await showDialog<String>(context: context, builder:
              (BuildContext context) {
                return AlertDialog(title: Text("today's service topic"),
                content: TextField(
                  controller: textDateController,
                  decoration: InputDecoration(hintText: "Enter topic"),
                ),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {
                        Navigator.of(context).pop(textDateController.text);
                      },
                    ),
                  ],
                );
              }
              );
              if (additionalText != null && additionalText.isNotEmpty){
                await provider.saveWorker(additionalText);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Attendance saved for today!'),
                  ),
                );
                await provider.notifyAbsentMembers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('WhatsApp notifications sent!'),
                  ),
                );
              }
            }),
            SizedBox(
              width: 40,
            ),
            button(context, "Show Attendance", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceDatesScreen(),
                ),
              );
            }),
            SizedBox(
              width: 40,
            ),
            button(context, "Department", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DepartmentList(),
                ),
              );
            }),
          ],
        ),
        SizedBox(
          height: 20,
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
                  child: Text('Errors: ${snapShot.hasError}'),
                );
              } else if (!snapShot.hasData || snapShot.data!.docs.isEmpty) {
                return Center(
                  child: Text('No Worker Added yet'),
                );
              } else {
                provider.setWorkers(snapShot.data!.docs);
                final filteredWorkers = provider.filteredWorkers;
                return AttendanceList(
                  filteredWorkers: filteredWorkers,
                  provider: provider,
                );
              }
            })
      ],
    );
  }
}

class AttendanceList extends StatelessWidget {
  const AttendanceList({
    super.key,
    required this.filteredWorkers,
    required this.provider,
  });

  final List<DocumentSnapshot<Object?>> filteredWorkers;
  final AttendanceProvider provider;

  @override
  Widget build(BuildContext context) {
    final color = MyColor();
    return Expanded(
      child: ListView.builder(
        itemCount: filteredWorkers.length,
        itemBuilder: (context, index) {
          final query = provider.searchQuery;
          DocumentSnapshot document = filteredWorkers[index];
          String documentId = document.id;
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          String noteText = data['name'];
          bool isPresent = data['isPresent'] ?? false;
          String churchDepartment = data['churchDepartment'];
          String level = data['level'];
          String gender = data['gender'];
          String birthDate = data['dateOfBirth'];
          Timestamp timeStamp = data['timeStamp'];
          int attendanceCount = data['attendanceCount'] ?? 0;
          String email = data['email'] ?? "N/A";
          return StreamBuilder<DocumentSnapshot>(stream: provider.getWorkerStream(documentId), builder: (context,snapShot){
            if (snapShot.connectionState == ConnectionState.waiting){
              return ListTile(leading: CircularProgressIndicator(), title: Text('Loading...'),);
            } else if (snapShot.hasError){
              return ListTile(title: Text('Error ${snapShot.hasError}'),);
            } else if (!snapShot.hasData || !snapShot.data!.exists){
              return ListTile(title: Text('No data found'),);
            } else {
              return ListTile(
                leading: Checkbox(
                    activeColor: color.primaryColor,
                    value: isPresent,
                    onChanged: (bool? value) {
                      if (value != null) {
                        provider.toggleWorkersAttendance(documentId, value);
                      }
                      print(isPresent);
                    }),
                title: RichText(
                  text: highlightText(
                    noteText,
                    query,
                    TextStyle(
                      color: color.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    TextStyle(
                      color: color.mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                subtitle: Text(
                  churchDepartment,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: color.primaryColor,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WorkerDetailsScreen(
                        worker: noteText,
                        phoneNumber: '1234',
                        churchDepartment: churchDepartment,
                        level: level,
                        gender: gender,
                        isPresent: isPresent,
                        timeStamp: timeStamp,
                        id: '',
                        documentId: documentId,
                        attendanceCount: attendanceCount,
                        birthDate: birthDate,
                        email: email,
                      ),
                    ),
                  );
                },
                trailing: Icon(Icons.edit),
              );
            }
          });
        },
      ),
    );
  }
}
