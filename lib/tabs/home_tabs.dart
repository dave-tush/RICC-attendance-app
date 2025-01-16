

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/members.dart';
import '../Models/workers.dart';
import '../Provider/attendance_provider.dart';
import '../screens/all_tabs.dart';
import '../screens/members_tab.dart';
import '../screens/workers_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AttendanceProvider>(context, listen: false).fetchData();
    print('object');
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance Sheet'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Workers'),
              Tab(text: 'Members'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AllTab(),
            WorkersTab(),
            MembersTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 200,
        child: Column(
          children: [
            ListTile(
              title: const Text('Add Worker'),
              onTap: () {
                _showAddWorkerForm(context);
              },
            ),
            ListTile(
              title: const Text('Add Member'),
              onTap: () {
                _showAddMemberForm(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberForm(BuildContext context) {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final member = Members(
                name: nameController.text,
                id: idController.text,
                role: roleController.text,
              );
              Provider.of<AttendanceProvider>(context, listen: false)
                  .addMembers(member);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddWorkerForm(BuildContext context) {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final positionController = TextEditingController();
    final schoolDepartmentController = TextEditingController();
    final churchDepartmentController = TextEditingController();
    final myFocusNode = FocusNode();
    final yFocusNode = FocusNode();
    final FocusNodes = FocusNode();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: const Text('Add Worker')),
        content: SizedBox(
          width: 1000,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              TextFormField(
                focusNode: myFocusNode,
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                focusNode: yFocusNode,
                controller: idController,
                decoration: const InputDecoration(labelText: 'ID'),
              ),
              TextFormField(

                controller: positionController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final worker = Worker(
                name: nameController.text,
                id: '',
                department: positionController.text,
              );
              Provider.of<AttendanceProvider>(context, listen: false).addWorker(worker);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

