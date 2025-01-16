import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/Models/members.dart';

import 'package:flutter/cupertino.dart';

import '../Models/workers.dart';

class AttendanceProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Worker> _worker = [];
  List<Members> _members = [];
  String _searchQuery = "";
  bool _isLoading = false;
bool get isLoading => _isLoading;

  Future<void> fetchData() async {
    _isLoading = true;

    //fetch workers
    try {
    final workerSnapShot = await _db.collection('Workers').get();
    _worker = workerSnapShot.docs
        .map((doc) => Worker.fromFirestore(doc.data(),doc.id))
        .toList();

    final memberSnapshot = await _db.collection('Members').get();
    _members = memberSnapshot.docs
        .map(
          (doc) => Members.fromFirestore(doc.data(),doc.id),
        )
        .toList();

    notifyListeners();
    } catch (e){
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> saveWorker(Worker worker) async{
    await _db.collection('Workers').doc(worker.id).set({
      'name': worker.name,
      'department': worker.department,
      'isPresent': worker.isPresent
    });
    fetchData();
  }

  Future<void> saveMembers(Members members)async{
    await _db.collection('Members').doc(members.id).set({
      'name': members.name,
      'role': members.role,
      'isPresent': members.isPresent,
    });
    fetchData();
  }

  Future<void> deleteWorker(Worker workers) async {
    await _db.collection('Workers').doc(workers.id).delete();
  }

  Future<void> deleteMember(Members member) async {
    await _db.collection('members').doc(member.id).delete();
    fetchData();
  }

  List<Worker> get workers => _worker
      .where((w) => w.name.toLowerCase().contains(_searchQuery))
      .toList();

  List<Members> get members => _members
      .where((m) => m.name.toLowerCase().contains(_searchQuery))
      .toList();

  List<dynamic> get all => [..._worker, ..._members];

  void addWorkers(Worker worker) {
    _worker.add(worker);
    notifyListeners();
  }
  Future<void> addWorker(Worker worker) async {
    await _db.collection('workers').add(worker.toFirestore());
    fetchData();
    print(_db.collection('Workers'));
    print('added');
    try {
      await _db.collection('workers').add(worker.toFirestore());
      fetchData();
      print(worker.name);
      print('successful');
    } catch (e) {
      print('Error adding worker: $e');
    }
    notifyListeners();
    print('good');
  }

  void addMembers(Members member) {
    _members.add(member);
    notifyListeners();
  }

  void toggleMembersAttendance(int index) {
    _members[index].isPresent = !_members[index].isPresent;
    notifyListeners();
  }

  void toggleWorkersAttendance(int index) {
    _worker[index].isPresent = !_worker[index].isPresent;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void deleteWorkers(Worker worker) {
    _worker.remove(worker);
    notifyListeners();
  }

  void deleteMembers(Members member) {
    _members.remove(member);
    notifyListeners();
  }

  void updateWorkers(int index, Worker updateWorker) {
    _worker[index] = updateWorker;
    notifyListeners();
  }

  void updateMembers(int index, Members updateMember) {
    _members[index] = updateMember;
    notifyListeners();
  }
}
