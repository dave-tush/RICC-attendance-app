import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/foundation/color.dart';
import 'package:first_project/screens/members_details_screens.dart';
import 'package:first_project/screens/workers_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/workers.dart';
import '../Models/members.dart';
import '../Provider/attendance_provider.dart';
import '../widgets/call_to_action_button.dart';
import '../widgets/high_light_text.dart';
import 'attendance_date_screen.dart';

class AllTab extends StatefulWidget {
  const AllTab({super.key});

  @override
  State<AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> {
  @override
  void initState() {
    super.initState();

    // Fetch data automatically on app start
    Provider.of<AttendanceProvider>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final all = provider.all;
    final colors = MyColor();
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration:  InputDecoration(
              focusColor: colors.mainColor,
              labelText: 'Search All',
              labelStyle: TextStyle(color: colors.primaryColor),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              provider.setSearchQuery(value);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            button(context, "Save workers Attendance", () async {
              await provider.saveWorker();
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
            ElevatedButton(
              onPressed: () {
                provider.pickExcelFile();
              },
              child: Text("Import Excel"),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        StreamBuilder<QuerySnapshot>(
            stream: provider.getMemberDataStream(),
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
                  child: Text('No member added yet'),
                );
              } else {
                provider.setAllUsers(snapShot.data!.docs);
                final filteredAll = provider.filteredAll;
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: false,
                    itemCount: filteredAll.length,
                    itemBuilder: (context, index) {
                      final query = provider.searchQuery;
                      DocumentSnapshot document = filteredAll[index];
                      String documentId = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String noteText = data['name'];
                      bool isPresent = data['isPresent'] ?? false;
                      return ListTile(
                        leading: Checkbox(
                            activeColor: colors.primaryColor,
                            value: isPresent,
                            onChanged: (value) {
                              provider.toggleAllAttendance(
                                  documentId, isPresent);
                            }),
                        title: RichText(
                          text: highlightText(
                            noteText,
                            query,
                            TextStyle(
                              color: colors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            TextStyle(
                              color: colors.mainColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        subtitle: Text('level'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MemberDetailsScreen(
                                  name: noteText,
                                  id: 'id',
                                  level: 'level',
                                  isPresent: isPresent),
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
