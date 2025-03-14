import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/foundation/color.dart';
import 'package:first_project/screens/members_attendance_date_screen.dart';
import 'package:first_project/screens/members_details_screens.dart';
import 'package:first_project/screens/workers_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/workers.dart';
import '../Provider/attendance_provider.dart';
import '../Models/members.dart';
import '../widgets/call_to_action_button.dart';
import '../widgets/high_light_text.dart';
import 'attendance_date_screen.dart';
import 'members_details_screen.dart';

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
              final textDateController = TextEditingController();
              String? additionalText = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("today's service topic"),
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
                  });
              if (additionalText != null && additionalText.isNotEmpty) {
                await provider.saveMember(additionalText);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Attendance saved for today!'),
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
                return MembersAttendance(
                    filteredMembers: filteredMembers,
                    provider: provider,
                    color: color);
              }
            })
      ],
    );
  }
}

class MembersAttendance extends StatelessWidget {
  const MembersAttendance({
    super.key,
    required this.filteredMembers,
    required this.provider,
    required this.color,
  });

  final List<DocumentSnapshot<Object?>> filteredMembers;
  final AttendanceProvider provider;
  final MyColor color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredMembers.length,
        itemBuilder: (context, index) {
          final query = provider.searchQuery;
          DocumentSnapshot document = filteredMembers[index];
          String documentId = document.id;
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          String name = data['name']  ?? "null";
          bool isPresent = data['isPresent'] ?? false;
          String level = data['level']  ?? "null";
          String gender = data['gender']  ?? "null";
          String whatsAppPhoneNumber = data['whatsAppPhoneNumber']  ?? "null";
          String address = data['address']  ?? "null";
          String dateOfBirth = data['dateOfBirth']  ?? "null";
          String phoneNumber = data['phoneNumber']  ?? "null";
          String firstTimer = data['firstTimer']  ?? "null";
          String department = data['department'] ?? "null";
          return ListTile(
            leading: Checkbox(
                activeColor: color.primaryColor,
                value: isPresent,
                onChanged: (value) {
                  provider.toggleMembersAttendance(documentId, isPresent);
                }),
            title: RichText(
              text: highlightText(
                name,
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
            subtitle: Text(
              department,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color.primaryColor,
                fontSize: 12,
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
              return  MembersDetailScreen(
                  members: Members(
                      name: name,
                      level: level,
                      gender: gender,
                      phoneNumber: phoneNumber,
                      dateOfBirth: dateOfBirth,
                      firstTimer: firstTimer,
                      address: address,
                      whatsAppPhoneNumber: whatsAppPhoneNumber,
                      type: 'members'),
                  documentId: documentId,
                );
              }));
            },
          );
        },
      ),
    );
  }
}
