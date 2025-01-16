import 'package:first_project/screens/members_details_screens.dart';
import 'package:first_project/screens/workers_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/workers.dart';
import '../Models/members.dart';
import '../Provider/attendance_provider.dart';

class AllTab extends StatelessWidget {
  const AllTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final all = provider.all;

    return Column(
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
        Expanded(
          child: ListView.builder(
            itemCount: all.length,
            itemBuilder: (context, index) {
              final item = all[index];
              return ListTile(
                leading: Checkbox(
                  value: item.isPresent,
                  onChanged: (value) {
                    if (item is Worker) {
                      provider.toggleWorkersAttendance(
                          provider.workers.indexOf(item));
                    } else if (item is Members) {
                      provider.toggleMembersAttendance(
                          provider.members.indexOf(item));
                    }
                  },
                ),
                title: Text(item.name),
                subtitle: Text(item is Worker ? item.department : item.role),
                onTap: () {
                  if (item is Worker) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WorkerDetailsScreen(worker: item),
                      ),
                    );
                  } else if (item is Members) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MemberDetailsScreen(member: item),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
