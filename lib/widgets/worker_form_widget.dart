import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../Models/workers.dart';
import '../Provider/attendance_provider.dart';
import '../foundation/color.dart';
import 'call_to_action_button.dart';

void showAddWorkerForm(BuildContext context) {
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
  final emailController = TextEditingController();
  showDialog(
      context: context,
      builder: (context) {
        final colors = MyColor();
        return AlertDialog(
          title: Center(
              child: Text(
            'Add Worker',
            style: TextStyle(
              color: colors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          )),
          content: SizedBox(
            width: 1000,
            child: Column(
              children: [
                TextFormField(
                  focusNode: myFocusNode,
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(
                      color: colors.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  focusNode: yFocusNode,
                  controller: dateOfBirthController,
                  decoration: InputDecoration(
                      labelText: 'Date Of Birth',
                      labelStyle: TextStyle(
                        color: colors.primaryColor,
                        fontSize: 16,
                      )),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  controller: phoneNumberController,
                  decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixText: countryCode,
                      labelStyle: TextStyle(
                        color: colors.primaryColor,
                        fontSize: 16,
                      )),
                ),
                TextFormField(
                  controller: schoolDepartmentController,
                  decoration: InputDecoration(
                      labelText: 'school Department',
                      labelStyle: TextStyle(
                        color: colors.primaryColor,
                        fontSize: 16,
                      )),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: colors.primaryColor,
                        fontSize: 16,
                      )),
                ),
                DropdownButtonFormField(
                    hint: Text(
                      'Church Department',
                      style: TextStyle(color: colors.primaryColor),
                    ),
                    value: provider.selectedLevel,
                    style: TextStyle(color: colors.mainColor),
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
                            child: Text(
                              '$churchDepartment DEPARTMENT',
                              style: TextStyle(
                                  color: colors.primaryColor, fontSize: 16),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.setChurchDepartment(value);
                      }
                    }),
                DropdownButtonFormField(
                    hint: Text('Level',
                        style: TextStyle(color: colors.primaryColor)),
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
                    hint: Text('Gender',
                        style: TextStyle(color: colors.primaryColor)),
                    value: provider.selectedGender,
                    items: ['Male', 'female']
                        .map(
                          (gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(
                              gender,
                              style: TextStyle(
                                color: colors.primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.setSelectedGender(value);
                      }
                    }),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: TextStyle(
                        color: colors.primaryColor,
                        fontSize: 16,
                      )),
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
            button(context, 'ADD', () {
              final worker = Worker(
                  name: nameController.text,
                  id: '',
                  schoolDepartment: schoolController.text,
                  timestamp: Timestamp.now(),
                  phoneNumber: countryCode + phoneNumberController.text,
                  level: provider.selectedLevel!,
                  churchDepartment: provider.churchDepartment!,
                  gender: provider.selectedGender!,
                  address: addressController.text,
                  dateOfBirth: dateOfBirthController.text,
                  attendanceCount: 0, email: '');
              Provider.of<AttendanceProvider>(context, listen: false)
                  .addWorker(context, worker, phoneNumberController.text);
              Navigator.of(context).pop();
            }),
          ],
        );
      });
}
