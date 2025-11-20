import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  // USERS ---------------------------------------------------------------------
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    await _users.doc(uid).set({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
      String uid) async {
    return _users.doc(uid).get();
  }

  Future<void> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? role,
    String? dob,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (role != null) data['role'] = role;
    if (dob != null) data['dob'] = dob;

    if (data.isNotEmpty) {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _users.doc(uid).set(data, SetOptions(merge: true));
    }
  }

  // MESSAGES ------------------------------------------------------------------
  CollectionReference<Map<String, dynamic>> _boardMessages(String boardId) =>
      _db.collection('boards').doc(boardId).collection('messages');

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String boardId) {
    return _boardMessages(boardId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String boardId,
    required String uid,
    required String displayName,
    required String text,
  }) async {
    await _boardMessages(boardId).add({
      'uid': uid,
      'displayName': displayName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
