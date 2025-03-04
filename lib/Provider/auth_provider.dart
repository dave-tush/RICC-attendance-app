import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthsProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;

  Future<void> signUp(String name,String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      // Add user data to Firestore
      await addUserData(_user!.uid, {
        'email': email,
        'name': name,
        'createdAt': Timestamp.now(),
      });

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      // Fetch user data from Firestore
      await fetchUserData(_user!.uid);

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> addUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  Future<void> fetchUserData(String uid) async {
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(uid).get();
    if (snapshot.exists) {
      print('User Data: ${snapshot.data()}');
    } else {
      print('No user data found');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
  Future<void> checkAuthentication () async {
    _user = _auth.currentUser;
    notifyListeners();
  }
}
