import 'package:first_project/screens/workers_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/attendance_provider.dart';

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
    final workers = provider.workers;

    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider,child){


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
            Expanded(
              child: ListView.builder(
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  return InkWell(
                    child: ListTile(
                      leading: Checkbox(
                          value: worker.isPresent,
                          onChanged: (value) {
                            provider.toggleWorkersAttendance(index);
                          }),
                      title: Text(worker.name),
                      subtitle: Text(worker.department),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              WorkerDetailsScreen(worker: worker)));
                      print("tapped");
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
