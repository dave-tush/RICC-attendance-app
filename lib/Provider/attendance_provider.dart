import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/Models/members.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../Models/workers.dart';

class AttendanceProvider with ChangeNotifier {
  final String whatsappToken =
      'EAAYZBrPpPlsgBO9w3MG6XNfmm10ZBvEvkf2SxspWxRLYsxzCWdYCIHt2VAKWEybv7ukeVvvFraqvJSgivByJHiKwHIbVsLx2CXV70yp7dLV9C1VE5Y0FqEgkXGamfErINoKiOuM119dk8eZCAOjWz7LKzbEbIRbVf34YmbZAj1HawgmizwapZAufGuL1PgwoXOVLPOrB4NZCXcNYLGkhnuoxiZARNgZD';
  final String phoneNumberID = '570357182827926';
  final String apiUrl = 'https://graph.facebook.com/v21.0';
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Worker> _worker = [];
  List<Members> _members = [];
  List<DocumentSnapshot> _work = [];
  List<DocumentSnapshot> _member = [];
  List<DocumentSnapshot> _allUser = [];
  String searchQuery = "";
  bool _isLoading = false;
  String? _selectedGender;
  String? _selectedLevel;
  String? _firstTimer;
  String? _department;
  Timer? _debounceTimer;
  String? profileImageUrl;
  bool _isPresent = true;
  final Map<String, String> _dateTextMap = {};

  Map<String, String> get dateTextMap => _dateTextMap;

  String? get selectedGender => _selectedGender;

  String? get selectedLevel => _selectedLevel;

  String? get department => _department;

  String? get firstTimer => _firstTimer;

  bool get isLoading => _isLoading;

  bool get isPresent => _isPresent;

  List<DocumentSnapshot> get allUser => _allUser;

  void addDateText(String date, String text) {
    _dateTextMap[date] = text;
    notifyListeners();
  }

  void setSelectedGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setFirstTimer(String firstTimer) {
    _firstTimer = firstTimer;
    notifyListeners();
  }

  void setSelectLevel(String level) {
    _selectedLevel = level;
    notifyListeners();
  }

  void setChurchDepartment(String department) {
    _department = department;
    notifyListeners();
  }
  void setSelectedDepartment (String? department){
    _department = department;
    notifyListeners();
  }
  List<DocumentSnapshot> get firstTimers {
    return _allUser.where((user) {
      final data = user.data() as Map<String, dynamic>;
      return data['firstTimer'] == 'Yes';
    }).toList();
  }

  List<String> get departments {
    final departments = <String>{};
    for (final user in _allUser) {
      final data = user.data() as Map<String, dynamic>;
      final department = data['churchDepartment'] ?? data['schoolDepartment'];
      departments.add(department);
    }
    return departments.toList();
  }
  List<DocumentSnapshot> get filteredByDepartment {
    if (_department == null || _department!.isEmpty) {
      return _allUser;
    }
    return _allUser.where((user) {
      final data = user.data() as Map<String, dynamic>;
      final department = data['churchDepartment'] ?? data['schoolDepartment'];
      return department == _department;
    }).toList();
  }
  Future<void> fetchData() async {
    _isLoading = true;
    //fetch workers
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in');
        return;
      }
      String uid = user.uid;
      final workSnapshot =
          await _db.collection('users').doc(uid).collection('workers').get();
      _worker = workSnapshot.docs
          .map((doc) => Worker.fromFirestore(doc.data(), doc.id))
          .toList();
      //fetch members
      final memberSnapshot =
          await _db.collection('users').doc(uid).collection('members').get();
      _members = memberSnapshot.docs
          .map(
            (doc) => Members.fromFirestore(doc.data(), doc.id),
          )
          .toList();
      _sortWorkersAlphabetically();
      notifyListeners();
    } catch (e, stacktrace) {
      print('Error fetching data: $e');
      print(stacktrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Add this method to handle saving all attendance
  Future<void> saveAllAttendance(String topic) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String uid = user.uid;
    final date = DateTime.now().toIso8601String().split('T').first;

    final attendanceDocRef = _db
        .collection('users')
        .doc(uid)
        .collection('attendance')
        .doc(date);

    // Save topic/text field
    await attendanceDocRef.set({
      'topic': topic,
      'date': date,
    }, SetOptions(merge: true));

    // Save workers
    await _saveCollectionAttendance(attendanceDocRef, 'workers', _work);

    // Save members
    await _saveCollectionAttendance(attendanceDocRef, 'members', _member);

    fetchData();
    notifyListeners();
  }

  List<DocumentSnapshot> getWorkersByDepartment(String department) {
    return _work.where((worker) {
      final data = worker.data() as Map<String, dynamic>;
      return data['churchDepartment'] == department;
    }).toList();
  }
  Future<void> _saveCollectionAttendance(
      DocumentReference attendanceDocRef,
      String collectionName,
      List<DocumentSnapshot> users
      ) async {
    final collectionRef = attendanceDocRef.collection(collectionName);

    for (final user in users) {
      final data = user.data() as Map<String, dynamic>;
      if (data['isPresent'] == true) {
        await collectionRef.doc(user.id).set({
          'name': data['name'],
          'department': data['churchDepartment'] ?? data['schoolDepartment'],
          'phoneNumber': data['phoneNumber'],
          'isPresent': true,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
  }
  Future<void> saveWorker(String additionalText) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String uid = user.uid;
    final date = DateTime.now().toIso8601String().split('T').first;

    final attendanceDocRef =
        _db.collection('users').doc(uid).collection('attendance').doc(date);

    final attendanceCollection = attendanceDocRef.collection('workers');

    bool atLeastOneWorkerPresent = false;
    List<DocumentSnapshot> updatedWorker = [];

    // Save the additional text
    await attendanceDocRef.set(
      {
        'additionalText': additionalText, // Ensure this field is saved
        'date': date,
      },
      SetOptions(merge: true),
    );

    print('Saving additionalText: $additionalText'); // Debug log

    for (final worker in _work) {
      final data = worker.data() as Map<String, dynamic>;
      if (data['isPresent'] == true) {
        atLeastOneWorkerPresent = true;
        DocumentReference workerRef = attendanceCollection.doc(worker.id);

        await _db.runTransaction((transaction) async {
          DocumentSnapshot workerDoc = await workerRef.get();
          int attendanceCount =
              workerDoc.exists && workerDoc['attendanceCount'] != null
                  ? workerDoc['attendanceCount'] as int
                  : 0;
          await transaction.set(
            workerRef,
            {
              'name': data['name'],
              'schoolDepartment': data['schoolDepartment'],
              'churchDepartment': data['churchDepartment'],
              'level': data['level'],
              'position': data['position'],
              'phoneNumber': data['phoneNumber'],
              'isPresent': data['isPresent'],
              'attendanceCount': attendanceCount + 1,
            },
            SetOptions(merge: true),
          );
          print('saved worker: ${data['name']} on $date');
        });
      }
      updatedWorker.add(worker);
    }

    if (!atLeastOneWorkerPresent) {
      print('No workers were present on $date');
    }

    _work = updatedWorker;
    fetchData();
  }

  Future<Map<String, dynamic>> fetchAttendanceDates() async {
    try {
      final db = FirebaseFirestore.instance;
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in');
        return {};
      }
      String uid = user.uid;
      final querySnapshot =
          await db.collection('users').doc(uid).collection('attendance').get();

      if (querySnapshot.docs.isEmpty) {
        print("No attendance records found");
        return {};
      }

      final Map<String, dynamic> attendanceData = {};
      for (final doc in querySnapshot.docs) {
        final date = doc.id.split('T').first;
        final additionalText = doc.get('additionalText') ??
            'No additional text'; // Handle missing field
        print('Fetched additionalText: $additionalText'); // Debug log
        attendanceData[date] = {
          'formattedDate': _getFormattedDate(date),
          'additionalText': additionalText,
        };
      }

      return attendanceData;
    } catch (e) {
      print("Error fetching attendance dates: $e");
      return {};
    }
  }
  Future<void> saveMember(String additionalText) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String uid = user.uid;
    final date = DateTime.now().toIso8601String().split('T').first;

    final attendanceDocRef =
    _db.collection('users').doc(uid).collection('attendance').doc(date);

    final attendanceCollection = attendanceDocRef.collection('members');

    bool atLeastOneMemberPresent = false;
    List<DocumentSnapshot> updatedMember = [];

    // Save the additional text
    await attendanceDocRef.set(
      {
        'additionalText': additionalText, // Ensure this field is saved
        'date': date,
      },
      SetOptions(merge: true),
    );

    print('Saving additionalText: $additionalText'); // Debug log

    for (final members in _member) {
      final data = members.data() as Map<String, dynamic>;
      if (data['isPresent'] == true) {
        atLeastOneMemberPresent = true;
        DocumentReference memberRef = attendanceCollection.doc(members.id);

        await _db.runTransaction((transaction) async {
          DocumentSnapshot memberDoc = await memberRef.get();
          int attendanceCount =
          memberDoc.exists && memberDoc['attendanceCount'] != null
              ? memberDoc['attendanceCount'] as int
              : 0;
          await transaction.set(
            memberRef,
            {
              'name': data['name'],
              'churchDepartment': data['churchDepartment'],
              'level': data['level'],
              'position': data['position'],
              'phoneNumber': data['phoneNumber'],
              'isPresent': data['isPresent'],
              'attendanceCount': attendanceCount + 1,
            },
            SetOptions(merge: true),
          );
          print('saved members: ${data['name']} on $date');
        });
      }
      updatedMember.add(members);
    }

    if (!atLeastOneMemberPresent) {
      print('No workers were present on $date');
    }

    _member = updatedMember;
    fetchData();
  }
  Future<void> saveMembers() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String uid = user.uid;
    final date = DateTime.now().toString().split('T').first;
    final attendanceCollection = _db
        .collection('users')
        .doc(uid)
        .collection('attendance')
        .doc(date)
        .collection('members');
    await _db
        .collection('users')
        .doc(uid)
        .collection('attendance')
        .doc(date)
        .set({});
    bool atLeastOneMemberPresent = false;
    List<DocumentSnapshot> updatedMember = [];
    for (final member in _member) {
      final data = member.data() as Map<String, dynamic>;
      if (data['isPresent'] == true) {
        atLeastOneMemberPresent = true;
        DocumentReference memberRef = attendanceCollection.doc(member.id);

        DocumentSnapshot memberDoc = await memberRef.get();
        int attendanceCount =
            memberDoc.exists && memberDoc['attendanceCount'] != null
                ? memberDoc['attendanceCount'] as int
                : 0;
        await memberRef.set({
          'attendanceCount': attendanceCount + 1,
        }, SetOptions(merge: true));
        await attendanceCollection.doc(member.id).set({
          'name': data['name'],
          'churchDepartment': data['churchDepartment'],
          'level': data['level'],
          'position': data['position'],
          'phoneNumber': data['phoneNumber'],
          'isPresent': data['isPresent'],
        });
        print('saved worker: ${data['name']} on $date');
      }
      updatedMember.add(member);
    }
    if (!atLeastOneMemberPresent) {
      print('No members were present on $date');
    }
    _work = updatedMember;
    fetchData();
    notifyListeners();
  }

  String _getFormattedDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMMM d, y').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAttendance(String date) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];
      String uid = user.uid;
      final attendanceCollection = _db
          .collection('users')
          .doc(uid)
          .collection('attendance')
          .doc(date)
          .collection('workers');

      final querySnapshot = await attendanceCollection.get();

      if (querySnapshot.docs.isEmpty) {
        print("No attendance records found for $date");
      }
      final Map<String, dynamic> attedanceData = {};
      for (final doc in querySnapshot.docs) {
        final date = doc.id.split('T').first;
        final additionalText = doc['additionalText'] as String?;
        attedanceData[date] = {
          'formattedDate': _getFormattedDate(date),
          'additionalText': additionalText,
        };
      }
      attedanceData;
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching attendance: $e");
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getAbsentWorker(String date) {
    final attendanceCollection =
        _db.collection('attendance').doc(date).collection('workers');
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

  List<DocumentSnapshot> get all => [..._work, ..._member];

  Future<void> addWorker(
      BuildContext context, Worker worker, String phoneNumber) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      String uid = user.uid;
      QuerySnapshot query = await _db
          .collection('users')
          .doc(uid)
          .collection('workers')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Worker with phone $phoneNumber already exists!'),
          ),
        );
        return;
      }
      await _db
          .collection('users')
          .doc(uid)
          .collection('workers')
          .add(worker.toFirestore());
      await _db
          .collection('users')
          .doc(uid)
          .collection('all')
          .add(worker.toFirestore());
      fetchData();
      notifyListeners();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Worker added successfully!')));
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

  Future<void> addMember(
      BuildContext context, Members member, String phoneNumber) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      String uid = user.uid;
      QuerySnapshot query = await _db
          .collection('users')
          .doc(uid)
          .collection('members')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Worker with phone $phoneNumber already exists!'),
          ),
        );
        return;
      }
      await _db
          .collection('users')
          .doc(uid)
          .collection('members')
          .add(member.toFirestore());
      await _db
          .collection('users')
          .doc(uid)
          .collection('all')
          .add(member.toFirestore());
      fetchData();
      notifyListeners();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Member added successfully!')));
    } catch (e) {
      print('Error adding worker: $e');
    }
  }

  Stream<QuerySnapshot>? getDataStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    String uid = user.uid;
    return _db.collection('users').doc(uid).collection('workers').snapshots();
  }

  Stream<DocumentSnapshot> getWorkerStream(String documentId) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.empty();
    String uid = user.uid;

    return _db
        .collection('users')
        .doc(uid)
        .collection('workers')
        .doc(documentId)
        .snapshots();
  }

  Stream<QuerySnapshot>? getMemberDataStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    String uid = user.uid;
    return _db.collection('users').doc(uid).collection('members').snapshots();
  }

  Stream<QuerySnapshot>? getAllDataStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    String uid = user.uid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('all')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot>? getAttendanceStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    String uid = user.uid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('attendance')
        .snapshots();
  }

  void setWorkers(List<DocumentSnapshot> worker) {
    _work = worker;
  }

  void setMembers(List<DocumentSnapshot> member) {
    _member = member;
  }

  void setAllUsers(List<DocumentSnapshot> all) {
    _allUser = all;
    notifyListeners();
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

  Future<void> toggleWorkersAttendance(String documentId, bool newValue) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String uid = user.uid;
    _db
        .collection('users')
        .doc(uid)
        .collection('workers')
        .doc(documentId)
        .update({'isPresent': newValue});
    _isPresent = newValue;
    print(newValue);
    notifyListeners();
    _isPresent = false;
    notifyListeners();
  }

  Future<void> toggleAllAttendance(
      String documentId, bool isPresent, String collectionType) async {
    bool updateIsPresent = !isPresent;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String uid = user.uid;
    try {
      final collection = collectionType == 'worker' ? 'workers' : 'members';
      _db
          .collection('users')
          .doc(uid)
          .collection(collection)
          .doc(documentId)
          .update({'isPresent': isPresent});


      final docRef =
          _db.collection('users').doc(uid).collection('all').doc(documentId);
      final doc = await docRef.get();
      if (doc.exists) {
        _db
            .collection('users')
            .doc(uid)
            .collection('all')
            .doc(documentId)
            .update({'isPresent': !isPresent});
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
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String uid = user.uid;
    _db
        .collection('users')
        .doc(uid)
        .collection('members')
        .doc(documentId)
        .update({'isPresent': updateIsPresent});
    notifyListeners();
  }

  void deleteWorkers(String documentId) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String uid = user.uid;
    _db
        .collection('users')
        .doc(uid)
        .collection('workers')
        .doc(documentId)
        .delete();
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

  Future<void> sendWhatsAppMessage(String name, String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      print('no phone number for $name skipping whatsapp message.');
      return;
    }
    final String url = '$apiUrl/$phoneNumberID/messages';
    final Map<String, dynamic> body = {
      'messaging_product': 'whatsapp',
      "to": phoneNumber,
      "type": "text",
      "text": {"body": "Hello $name, you were not in Church today  "}
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

  Future<void> notifyAbsentMembers() async {
    try {
      final absentWorker = _work.where((worker) {
        final data = worker.data() as Map<String, dynamic>?;
        return data != null &&
            data.containsKey('isPresent') &&
            data['isPresent'] == false;
      }).toList();

      if (absentWorker.isEmpty) {
        print('no absent workers to notify');
        return;
      }
      await Future.wait(absentWorker.map((worker) async {
        final data = worker.data() as Map<String, dynamic>;
        final String name = data['name'] ?? 'user';
        final String phoneNumber = data['phoneNumber'] ?? '';
        if (phoneNumber.isNotEmpty) {
          // await sendWhatsAppMessage(name, phoneNumber);
        }
      }));
      print('${absentWorker.length} absent workers notified.');
      notifyListeners();
    } catch (e) {
      print('Error notifying absent members: $e');
    }
    notifyListeners();
  }

  Future<void> rectifyAbsentMembers() async {
    for (var workers in _work) {
      Map<String, dynamic>? data = workers.data() as Map<String, dynamic>;
      if (data.containsKey('isPresent')) {
        bool isPresent = data['isPresent'];
        final String name = data['name'] ?? 'user';
        final String phoneNumber = data['phoneNumber'] ?? '';
        if (isPresent == false) {
          await sendWhatsAppMessage(name, phoneNumber);
        }
      } else {
        print('error');
      }
    }
    notifyListeners();
  }
}
