import 'package:flutter/material.dart';

import '../constants/departments.dart';
import 'department_screen.dart';

class DepartmentList extends StatelessWidget {
  const DepartmentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Church Departments'),
      ),
      body: ListView.builder(
        itemCount: churchDepartment.length,
        itemBuilder: (context, index) {
          final department = churchDepartment[index];
          return ListTile(
            title: Text('$department DEPARTMENT'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DepartmentScreen(
                    department: '$department DEPARTMENT',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
