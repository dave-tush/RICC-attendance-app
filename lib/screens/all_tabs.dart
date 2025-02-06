import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/screens/members_details_screens.dart';
import 'package:first_project/screens/workers_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/workers.dart';
import '../Models/members.dart';
import '../Provider/attendance_provider.dart';
import '../widgets/high_light_text.dart';

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

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search All',
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
                            value: isPresent,
                            onChanged: (value) {
                              provider.toggleAllAttendance(
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
