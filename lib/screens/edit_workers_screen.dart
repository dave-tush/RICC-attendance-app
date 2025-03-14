import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Models/workers.dart';
import '../Provider/attendance_provider.dart';

class EditWorkerScreen extends StatefulWidget {
  final String documentId;

  const EditWorkerScreen({super.key, required this.documentId});

  @override
  _EditWorkerScreenState createState() => _EditWorkerScreenState();
}

class _EditWorkerScreenState extends State<EditWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsAppController;
  late TextEditingController _addressController;
  late TextEditingController _levelController;
  late TextEditingController _dateOfBirthController;
  String? _selectedGender;
  String? _selectedDepartment;
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _departments = [
    'Music',
    'Ushering',
    'Media',
    'Technical',
    'Sanitation'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _whatsAppController = TextEditingController();
    _addressController = TextEditingController();
    _levelController = TextEditingController();
    _dateOfBirthController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsAppController.dispose();
    _addressController.dispose();
    _levelController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Worker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveChanges(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: Provider.of<AttendanceProvider>(context, listen: false)
            .getWorkerStream(widget.documentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Worker not found'));
          }

          final workerData = snapshot.data!.data() as Map<String, dynamic>;
          if (_nameController.text.isEmpty) {
            _nameController.text = workerData['name'];
            _phoneController.text = workerData['phoneNumber'];
            _whatsAppController.text = workerData['whatsAppNumber'];
            _addressController.text = workerData['address'];
            _levelController.text = workerData['level'];
            _dateOfBirthController.text = workerData['dateOfBirth'];
            _selectedGender = workerData['gender'];
            _selectedDepartment = workerData['churchDepartment'];
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _whatsAppController,
                    decoration: const InputDecoration(labelText: 'WhatsApp Number'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextFormField(
                    controller: _levelController,
                    decoration: const InputDecoration(labelText: 'Level'),
                  ),
                  TextFormField(
                    controller: _dateOfBirthController,
                    decoration: const InputDecoration(labelText: 'Date of Birth'),
                    onTap: () => _selectDate(context),
                    readOnly: true,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: _genders.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a gender';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: const InputDecoration(labelText: 'Department'),
                    items: _departments.map((String department) {
                      return DropdownMenuItem<String>(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a department';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _saveChanges(context),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveChanges(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final updatedWorker = Worker(
        id: widget.documentId,
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        whatsAppNumber: _whatsAppController.text,
        address: _addressController.text,
        level: _levelController.text,
        dateOfBirth: _dateOfBirthController.text,
        gender: _selectedGender!,
        churchDepartment: _selectedDepartment!,
        timestamp: Timestamp.now(),
        attendanceCount: 1,
        type: 'workers',
      );

      try {
        await Provider.of<AttendanceProvider>(context, listen: false)
            .updateWorkerInFirestore(widget.documentId, updatedWorker);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating worker: $e')),
        );
      }
    }
  }
}
