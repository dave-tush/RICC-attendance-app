import 'package:first_project/Provider/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/workers.dart';

class WorkerDetailsScreen extends StatelessWidget {
  final Worker worker;

  const WorkerDetailsScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final index = provider.workers.indexOf(worker);
    return Scaffold(
      appBar: AppBar(
        title: Text(worker.name),
        actions: [
          IconButton(onPressed: (){
            provider.deleteWorkers(worker);
            Navigator.pop(context);
          }, icon: Icon(Icons.delete))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${worker.name}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'ID: ${worker.id}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Position: ${worker.department}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Present: ${worker.isPresent ? 'Yes' : 'No'}',
              style: const TextStyle(fontSize: 18),
            ),
            ElevatedButton(onPressed: (){
              _showEditDialog(context, provider, worker, index);
    }, child: Text("Edit"),)
          ],
        ),
      ),
    );
  }
  void _showEditDialog(
      BuildContext context, AttendanceProvider provider, Worker worker, int index) {
    final nameController = TextEditingController(text: worker.name);
    final positionController = TextEditingController(text: worker.department);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Worker'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Position'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedWorker = Worker(
                  name: nameController.text,
                  id: worker.id,
                  department: positionController.text,
                  isPresent: worker.isPresent,
                );
                provider.updateWorkers(index, updatedWorker);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
}}
