import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              title: const Text('Add Workers'),
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
    final provider = AttendanceProvider();
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final levelController = TextEditingController();
    final doBController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: SizedBox(
          width: 1000,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              DropdownButtonFormField(
                  hint: Text('Level'),
                  value: provider.selectedLevel,
                  items: [
                    'Pre Degree',
                    '100 Level',
                    '200 Level',
                    '300 Level',
                    '400 Level',
                    '500 Level',
                    'Graduate',
                  ]
                      .map((level) =>
                          DropdownMenuItem(value: level, child: Text(level)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSelectLevel(value);
                    }
                  }),
              DropdownButtonFormField(
                  hint: Text('Gender'),
                  value: provider.selectedGender,
                  items: ['Male', 'female']
                      .map((gender) =>
                      DropdownMenuItem(value: gender, child: Text(gender)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSelectedGender(value);
                    }
                  }),
              TextField(
                controller: doBController,
                decoration: const InputDecoration(labelText: 'Date Of Birth'),
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
              final member = Members(
                name: nameController.text,
                id: idController.text,
                level: levelController.text,
                gender: provider.selectedGender!,
              );
              Provider.of<AttendanceProvider>(context, listen: false)
                  .addMember(member);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddWorkerForm(BuildContext context) {
    String countryCode = '234';
    final nameController = TextEditingController();
    final dateOfBirthController = TextEditingController();
    final addressController = TextEditingController();
    final schoolDepartmentController = TextEditingController();
    final phoneNumberController = TextEditingController();
    final schoolController = TextEditingController();
    final myFocusNode = FocusNode();
    final yFocusNode = FocusNode();
    final provider = AttendanceProvider();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: const Text('Add Worker')),
        content: SizedBox(
          width: 1000,
          child: Column(
            children: [
              TextFormField(
                focusNode: myFocusNode,
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                focusNode: yFocusNode,
                controller: dateOfBirthController,
                decoration: const InputDecoration(labelText: 'Date Of Birth'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                controller: phoneNumberController,
                decoration:  InputDecoration(
                    labelText: 'Phone Number', prefixText: countryCode),
              ),
              TextFormField(
                controller: schoolDepartmentController,
                decoration:
                    const InputDecoration(labelText: 'school Department'),
              ),
              DropdownButtonFormField(
                  hint: Text('Church Department'),
                  value: provider.selectedLevel,
                  items: [
                    'MINSTREL',
                    'SOUND',
                    'MEDIA',
                    'LIGHT',
                    'MAINTENANCE',
                    'SANCTUARY',
                    'HOSPITALITY',
                    'COMMUNICATION',
                    'PROTOCOL',
                    'USHERING',
                    'EVANGELISM',
                    'WATCHMEN',
                    'FOLLOW_UP',
                    'FINANCE',
                  ]
                      .map(
                        (churchDepartment) => DropdownMenuItem(
                          value: '$churchDepartment DEPARTMENT',
                          child: Text('$churchDepartment DEPARTMENT'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setChurchDepartment(value);
                    }
                  }),
              DropdownButtonFormField(
                  hint: Text('Level'),
                  value: provider.selectedLevel,
                  items: [
                    'Pre Degree',
                    '100 Level',
                    '200 Level',
                    '300 Level',
                    '400 Level',
                    '500 Level',
                    'Graduate',
                  ]
                      .map((level) =>
                          DropdownMenuItem(value: level, child: Text(level)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSelectLevel(value);
                    }
                  }),
              DropdownButtonFormField(
                  hint: Text('Gender'),
                  value: provider.selectedGender,
                  items: ['Male', 'female']
                      .map((gender) =>
                          DropdownMenuItem(value: gender, child: Text(gender)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSelectedGender(value);
                    }
                  }),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
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
                schoolDepartment: schoolController.text,
                timestamp: Timestamp.now(),
                phoneNumber:countryCode+phoneNumberController.text,
                level: provider.selectedLevel!,
                churchDepartment: provider.churchDepartment!,
                gender: provider.selectedGender!,
                address: addressController.text,
                dateOfBirth: dateOfBirthController.text
              );
              Provider.of<AttendanceProvider>(context, listen: false)
                  .addWorker(context,worker,phoneNumberController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
