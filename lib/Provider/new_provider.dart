import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/members.dart';
import '../Models/workers.dart';


class AttendanceProviders with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Worker> _workers = [];
  List<Members> _members = [];

  List<Worker> get workers => _workers;
  List<Members> get members => _members;

  // Fetch data from Firestore
  Future<void> fetchData() async {
    try {
      final workerSnapshot = await _db.collection('workers').get();
      _workers = workerSnapshot.docs
          .map((doc) => Worker.fromFirestore(doc.data(), doc.id))
          .toList();

      final memberSnapshot = await _db.collection('members').get();
      _members = memberSnapshot.docs
          .map((doc) => Members.fromFirestore(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Add a new worker
  Future<void> addWorker(Worker worker) async {
    try {
      await _db.collection('workers').add(worker.toFirestore());
      fetchData();
    } catch (e) {
      print('Error adding worker: $e');
    }
  }

  // Add a new member
  Future<void> addMember(Members member) async {
    try {
      await _db.collection('members').add(member.toFirestore());
      fetchData();
    } catch (e) {
      print('Error adding member: $e');
    }
  }

  // Delete a worker
  Future<void> deleteWorker(String id) async {
    try {
      await _db.collection('workers').doc(id).delete();
      fetchData();
    } catch (e) {
      print('Error deleting worker: $e');
    }
  }

  // Delete a member
  Future<void> deleteMember(String id) async {
    try {
      await _db.collection('members').doc(id).delete();
      fetchData();
    } catch (e) {
      print('Error deleting member: $e');
    }
  }
}
