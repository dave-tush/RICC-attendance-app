import 'package:first_project/foundation/color.dart';
import 'package:first_project/widgets/call_to_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/members.dart';
import '../Provider/attendance_provider.dart';

void showAddMemberForm(BuildContext context) {
  final provider = AttendanceProvider();
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final levelController = TextEditingController();
  final doBController = TextEditingController();

  final colors = MyColor();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Add Member',
        style: TextStyle(
          color: colors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 1000,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: colors.primaryColor,
                    fontSize: 16,
                  )),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(
                    color: colors.primaryColor,
                    fontSize: 16,
                  )),
            ),
            DropdownButtonFormField(
                hint: Text(
                  'Level',
                  style: TextStyle(color: colors.primaryColor),
                ),
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
                    .map(
                      (level) => DropdownMenuItem(
                        value: level,
                        child: Text(
                          level,
                          style: TextStyle(
                              color: colors.primaryColor, fontSize: 16),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.setSelectLevel(value);
                  }
                }),
            DropdownButtonFormField(
                hint: Text(
                  'Gender',
                  style: TextStyle(color: colors.primaryColor),
                ),
                value: provider.selectedGender,
                items: ['Male', 'female']
                    .map(
                      (gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(
                          gender,
                          style: TextStyle(
                              color: colors.primaryColor, fontSize: 16),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.setSelectedGender(value);
                  }
                }),
            TextField(
              controller: doBController,
              decoration: InputDecoration(
                  labelText: 'Date Of Birth',
                  labelStyle: TextStyle(
                    color: colors.primaryColor,
                    fontSize: 16,
                  )),
            ),
          ],
        ),
      ),
      actions: [
        button(context, 'ADD', () {
          final member = Members(
            name: nameController.text,
            level: levelController.text,
            gender: provider.selectedGender!,
            phoneNumber: phoneNumberController.text,
            dateOfBirth: doBController.text,
          );
          Provider.of<AttendanceProvider>(context, listen: false)
              .addMember(context, member, phoneNumberController.text);
          Navigator.of(context).pop();
        }),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
