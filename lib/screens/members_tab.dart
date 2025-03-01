import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/foundation/color.dart';
import 'package:first_project/screens/members_attendance_date_screen.dart';
import 'package:first_project/screens/members_details_screens.dart';
import 'package:first_project/screens/workers_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/attendance_provider.dart';
import '../Models/members.dart';
import '../widgets/call_to_action_button.dart';
import '../widgets/high_light_text.dart';
import 'attendance_date_screen.dart';

class MembersTab extends StatelessWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Members',
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
            button(context, "Save members Attendance", () async {
              await provider.saveMembers();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Attendance saved for today!'),
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
                  builder: (context) => MembersAttendanceDateScreen(),
                ),
              );
            }),
            SizedBox(
              width: 40,
            ),
          ],
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
                provider.setMembers(snapShot.data!.docs);
                final filteredMembers = provider.filteredMembers;
                final color = MyColor();
                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, index) {
                      final query = provider.searchQuery;
                      DocumentSnapshot document = filteredMembers[index];
                      String documentId = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String noteText = data['name'];
                      bool isPresent = data['isPresent'] ?? false;
                      String department = data ['department'] ?? "null";
                      return ListTile(
                        leading: Checkbox(
                            activeColor: color.primaryColor,
                            value: isPresent,
                            onChanged: (value) {
                              provider.toggleMembersAttendance(
                                  documentId, isPresent);
                            }),
                        title: RichText(
                          text: highlightText(
                            noteText,
                            query,
                            TextStyle(
                                color: color.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                            TextStyle(
                              color: color.mainColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        subtitle: Text(department,style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: color.primaryColor,
                          fontSize: 12,
                        ),),
                        onTap: () {
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
