import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:first_project/Models/members.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

import '../Models/workers.dart';

class AttendanceProvider with ChangeNotifier {
  final String whatsappToken =
      'EAAPQMPBzDt4BOw3WYVD8JBWYZAlw9dg8SdFqxSnb9Q87Rt4Afaqs941pvpsEjAKAeDKeQGPU1GZAkE4cdpNeF7HQvqNYxfLVTvZAMlO5b8nEZAS1bplQNnOfhZBXb0XG1Wy8T1HvvJTZAMWZCP9D2wjGV9O0tWZAIEnn4w86UeyhJvExy29ZCSStSlZAMKQ89r1n28kgHdZBoAAqZCEZBZACjR6A0E1HtQdtUZD';
  final String phoneNumberID = '504681519406167';
  final String apiUrl = 'https://graph.facebook.com/v21.0';
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Worker> _worker = [];
  List<Members> _members = [];
  List<DocumentSnapshot> _work = [];
  List<DocumentSnapshot> _member = [];
  String searchQuery = "";
  bool _isLoading = false;
  String? _selectedGender;
  String? _selectedLevel;
  String? _churchDepartment;
  Timer? _debounceTimer;

  String? get selectedGender => _selectedGender;

  String? get selectedLevel => _selectedLevel;

  String? get churchDepartment => _churchDepartment;

  bool get isLoading => _isLoading;

  void setSelectedGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setSelectLevel(String level) {
    _selectedLevel = level;
    notifyListeners();
  }

  void setChurchDepartment(String churchDepartment) {
    _churchDepartment = churchDepartment;
    notifyListeners();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    //fetch workers
    try {
      final workerSnapShot = await _db.collection('Workers').get();
      _worker = workerSnapShot.docs
          .map((doc) => Worker.fromFirestore(doc.data(), doc.id))
          .toList();
      //fetch members
      final memberSnapshot = await _db.collection('Members').get();
      _members = memberSnapshot.docs
          .map(
            (doc) => Members.fromFirestore(doc.data(), doc.id),
          )
          .toList();
      _sortWorkersAlphabetically();
      notifyListeners();
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveWorker() async {
    final date = DateTime.now().toString().split('T').first;
    final attendanceCollection =
        _db.collection('attendance').doc(date).collection('worker');
    await _db.collection('attendance').doc(date).set({});
    bool atLeastOneWorkerPresent = false;
    for (final worker in _work) {
      final data = worker.data() as Map<String, dynamic>;
      if (data['isPresent'] == true){
        atLeastOneWorkerPresent = true;
      await attendanceCollection.doc(worker.id).set({
        'name': data['name'],
        'schoolDepartment': data['schoolDepartment'],
        'churchDepartment': data['churchDepartment'],
        'level': data['level'],
        'position': data['position'],
        'phoneNumber': data['phoneNumber'],
        'isPresent': data['isPresent'],
      });
      print('saved worker: ${data['name']} on $date');
      }
    }
    if (!atLeastOneWorkerPresent) {
      print('No workers were present on $date');
    }
    fetchData();
  }
  Future<List<Map<String, dynamic>>> fetchAttendance(String date) async {
    try {
      final db = FirebaseFirestore.instance;
      final attendanceCollection = _db.collection('attendance').doc(date).collection('workers');

      final querySnapshot = await attendanceCollection.get();

      if (querySnapshot.docs.isEmpty) {
        print("No attendance records found for $date");
      } else {
        print("Fetched ${querySnapshot.docs.length} members for $date");
      }

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching attendance: $e");
      return [];
    }
  }

  Future<void> saveMembers() async {
    final date = DateTime.now().toString().split('T').first;
    final attendanceCollection =
    _db.collection('attendance').doc(date).collection('members');
    for (final member in _member) {
      final data = member.data() as Map<String, dynamic>;
      await attendanceCollection.doc(member.id).set({
        'name': data['worker'],
        'schoolDepartment': data['schoolDepartment'],
        'churchDepartment': data['churchDepartment'],
        'level': data['level'],
        'position': data['position'],
        'phoneNumber': data['phoneNumber'],
        'isPresent': data['isPresent'],
      });
    }
    fetchData();
  }

  Stream<List<Map<String, dynamic>>> getAbsentWorker(String date) {
    final attendanceCollection =
        _db.collection('attendance').doc(date).collection('worker');
    return attendanceCollection
        .where('isPresent', isEqualTo: false)
        .snapshots()
        .map((snapShot) {
      return snapShot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> deleteWorker(String documentId) async {
    await _db.collection('workers').doc(documentId).delete();
    fetchData();
    notifyListeners();
  }

  List<Members> get members => _members
      .where((m) => m.name.toLowerCase().contains(searchQuery))
      .toList();

  List<dynamic> get all => [..._worker, ..._members];

  Future<void> addWorker(BuildContext context,Worker worker,String phoneNumber) async {
    try {
      QuerySnapshot query = await _db.collection('workers').where('phoneNumber',isEqualTo: phoneNumber).get();
      if(query.docs.isNotEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Worker with phone $phoneNumber already exists!'))
        );
        return;
      }
      await _db.collection('workers').add(worker.toFirestore());
      await _db.collection('all').add(worker.toFirestore());
      fetchData();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Worker added successfully!'))
      );
    } catch (e) {
      print('Error adding worker: $e');
    }
  }

  void _sortWorkersAlphabetically() {
    _work.sort((a, b) {
      final nameA = (a['name'] ?? '').toString().toLowerCase();
      final nameB = (b['name'] ?? '').toString().toLowerCase();
      return nameA.compareTo(nameB);
    });
    notifyListeners();
  }

  Future<void> addMember(Members member) async {
    try {
      await _db.collection('members').add(member.toFirestore());
      await _db.collection('all').add(member.toFirestore());
    } catch (e) {
      print('Error adding member: $e');
    }
  }

  Stream<QuerySnapshot> getDataStream() {
    return _db.collection('workers').snapshots();
  }

  Stream<QuerySnapshot> getMemberDataStream() {
    return _db.collection('members').snapshots();
  }

  Stream<QuerySnapshot> getAllDataStream() {
    return _db.collection('all').snapshots();
  }
  Stream<QuerySnapshot> getAttendanceStream(){
    return _db.collection('attendance').snapshots();
  }

  void setWorkers(List<DocumentSnapshot> worker) {
    _work = worker;
  }

  void setMembers(List<DocumentSnapshot> member) {
    _member = member;
  }

  void setAllUsers(List<DocumentSnapshot> all) {
    var users = [..._work, ..._member];
    users = all;
  }

  // Set search query
  void setSearchQuery(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      searchQuery = query.toLowerCase();
      notifyListeners();
    });
  }

  // Get filtered workers based on the search query
  List<DocumentSnapshot> get filteredWorkers {
    if (searchQuery.isEmpty) {
      return _work;
    }
    return _work.where((worker) {
      final data = worker.data() as Map<String, dynamic>;
      final name = data['name']?.toLowerCase() ?? '';
      final department = data['schoolDepartment']?.toLowerCase() ?? '';
      return name.contains(searchQuery) || department.contains(searchQuery);
    }).toList();
  }

  List<DocumentSnapshot> get filteredAll {
    if (searchQuery.isEmpty) {
      return [..._work, ..._member];
    }

    final filterWorker = _work.where((worker) {
      final data = worker.data() as Map<String, dynamic>;
      final name = data['name']?.toLowerCase() ?? '';
      final department = data['schoolDepartment']?.toLowerCase() ?? '';
      return name.contains(searchQuery) || department.contains(searchQuery);
    }).toList();
    final filterMember = _member.where((member) {
      final data = member.data() as Map<String, dynamic>;
      final name = data['name']?.toLowerCase() ?? '';
      final department = data['level']?.toLowerCase() ?? '';
      return name.contains(searchQuery) || department.contains(searchQuery);
    }).toList();
    return [...filterWorker, ...filterMember];
  }

  // Get filtered members based on the search query
  List<DocumentSnapshot> get filteredMembers {
    if (searchQuery.isEmpty) {
      return _member;
    }
    return _member.where((member) {
      final data = member.data() as Map<String, dynamic>;
      final name = data['name']?.toLowerCase() ?? '';
      final department = data['level']?.toLowerCase() ?? '';
      return name.contains(searchQuery) || department.contains(searchQuery);
    }).toList();
  }

  Future<void> toggleWorkersAttendance(
      String documentId, bool isPresent) async {
    bool updateIsPresent = !isPresent;
    _db
        .collection('workers')
        .doc(documentId)
        .update({'isPresent': updateIsPresent});
    notifyListeners();
  }

  Future<void> toggleAllAttendance(String documentId, bool isPresent) async {
    bool updateIsPresent = !isPresent;
    try {
      final docRef = _db.collection('all').doc(documentId);
      final doc = await docRef.get();
      if (doc.exists) {
        _db
            .collection('all')
            .doc(documentId)
            .update({'isPresent': updateIsPresent});
        notifyListeners();
      } else {
        print('Document not found. You can create it.');
        await docRef.set({'isPresent': !isPresent});
        print(updateIsPresent);
      }
    } catch (e) {
      print('Error updating attendance: $e');
    }
  }

  void toggleMembersAttendance(String documentId, bool isPresent) {
    bool updateIsPresent = !isPresent;
    _db
        .collection('members')
        .doc(documentId)
        .update({'isPresent': updateIsPresent});
    notifyListeners();
  }

  void deleteWorkers(String documentId) {
    _db.collection('workers').doc(documentId).delete();
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

  Future<void> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'xlsm'],
    );
    if (result != null) {
      final bytes = result.files.single.bytes;
      if (bytes != null) {
        readExcelFile(bytes);
      }
    }
  }

  void readExcelFile(Uint8List bytes) {
    var excel = Excel.decodeBytes(bytes);
    for (var table in excel.tables.keys) {
      var rows = excel.tables[table]?.rows;
      if (rows != null) {
        for (var row in rows) {
          print(row.map((cell) => cell?.value).toList());
        }
      }
    }
  }

  void uploadAttendanceData(List<dynamic> row) async {
    if (row.isNotEmpty) {
      try {
        await _db.collection('worker').add({
          'Name': row[0],
          'Contact': row[1],
          'Address': row[2],
          'D.O.B': row[3],
          'Level': row[4],
          'Gender': row[5],
          'First time': row[6],
          'Department': row[7],
          'Check in3': row[8],
          '22/01/2025': row[9],
          'Check in4': row[10],
          '22/01/2025': row[11],
        });
        print('data uploaded successfully');
      } catch (e) {
        print('Error uploading: $e');
      }
    }
  }

  Future<void> sendWhatsAppMessage() async {
    final String url = '$apiUrl/$phoneNumberID/messages';
    for (var workers in _work) {
      Map<String, dynamic>? data = workers.data() as Map<String, dynamic>;
String phoneNumber = data['phoneNumber'] ?? '';
      final Map<String, dynamic> body = {
        'messaging_product': 'whatsapp',
        "to": phoneNumber,
        "type": "text",
        "text": {"body": "Hello ${data['name']}, just testing the whatsapp API "}
      };
      print(phoneNumber);
      try {
        final response = await http.post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $whatsappToken',
              'Content-Type': 'application/json'
            },
            body: jsonEncode(body));
        if (response.statusCode == 200) {
          print('message successfully sent to:');
        } else {
          print('Failed to send message: ${response.body}');
        }
      } catch (e) {
        print('Error sending whatsapp message: $e');
      }
      notifyListeners();
    }
  }

  Future<void> notifyAbsentMembers() async {
    for (var workers in _work) {
      Map<String, dynamic>? data = workers.data() as Map<String, dynamic>;

      if (data != null && data.containsKey('isPresent')) {
        bool isPresent = data['isPresent'] ?? false;
        if (isPresent == false) {
          await sendWhatsAppMessage();
        }
      } else {
        print('error');
      }
    }
    notifyListeners();
  }
}
