import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/screens/members_details_screens.dart';
import 'package:first_project/screens/workers_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/attendance_provider.dart';
import '../Models/members.dart';
import '../widgets/high_light_text.dart';

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
                      return ListTile(
                        leading: Checkbox(
                            value: isPresent,
                            onChanged: (value) {
                              provider.toggleMembersAttendance(
                                  documentId, isPresent);
                            }),
                        title: RichText(
                          text: highlightText(
                            noteText,
                            query,
                            TextStyle(color: Colors.black),
                            TextStyle(color: Colors.blue),
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
