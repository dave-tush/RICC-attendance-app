import 'package:first_project/screens/members_details_screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/attendance_provider.dart';
import '../Models/members.dart';

class MembersTab extends StatelessWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final members = provider.members;

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
        Expanded(
          child: ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                leading: Checkbox(
                    value: member.isPresent,
                    onChanged: (value) {
                      provider.toggleMembersAttendance(index);
                    }),
                title: Text(member.name),
                subtitle: Text(member.role),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MemberDetailsScreen(member: member),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
