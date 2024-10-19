import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to create a user in Firestore
  Future<void> createUserInFirestore(User user) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Check if user document already exists
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        // If the user doesn't exist in Firestore, create a new user document
        await _firestore.collection('users').doc(currentUser.uid).set({
          'email': currentUser.email,
          'displayName': currentUser.displayName,
          'photoURL': currentUser.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }




// Collection reference for complaints
  final CollectionReference complaints =
  FirebaseFirestore.instance.collection('complaints');

  // Collection reference for users (used as a foreign key)
  final CollectionReference users =
  FirebaseFirestore.instance.collection('users');

  // Reference to the 'feedback' subcollection within a specific 'complaint' document
  CollectionReference feedback(String complaintId) {
    return complaints.doc(complaintId).collection('feedback');
  }

  /// Get all complaints stream
  Stream<QuerySnapshot> getComplaintStream() {
    return complaints.snapshots();
  }

  /// Add a new complaint to the collection
  Future<void> addComplaint({
    required String complaintId,
    required String address,
    required String complaintTitle,
    required String date,
    required String deptName,
    required String details,
    required String fileUrl,
    required bool notifyMe,
    required String pincode,
    required String email,
    required String status,
  }) {
    return complaints.doc(complaintId).set({
      'complaint_id': complaintId,
      'address': address,
      'complaint_title': complaintTitle,
      'date': date,
      'dept_name': deptName,
      'details': details,
      'file_url': fileUrl,
      'notify_me': notifyMe,
      'pincode': pincode,
      'email': email,
      'status': "pending",
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get a specific complaint by ID
  Future<DocumentSnapshot> getComplaintById(String complaintId) async {
    return await complaints.doc(complaintId).get();
  }

  /// Add feedback to a specific complaint
  Future<void> addFeedback({
    required String complaintId,
    required String feedbackId,
    required String email,
    required int timeliness,
    required int effectiveness,
    required int communication,
    String? comments,
  }) {
    return feedback(complaintId).doc(feedbackId).set({
      'feedback_id': feedbackId,
      'complaint_id': complaintId,
      'email': email,
      'timeliness': timeliness,
      'effectiveness': effectiveness,
      'communication': communication,
      'comments': comments ?? '',
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get feedback stream for a specific complaint
  Stream<QuerySnapshot> getFeedbackStream(String complaintId) {
    return feedback(complaintId).snapshots();
  }

  /// Get all feedback for a specific complaint
  Future<QuerySnapshot> getAllFeedbackForComplaint(String complaintId) {
    return feedback(complaintId).get();
  }

  /// Update the status of a complaint (optional, if needed)
  Future<void> updateComplaintStatus(String complaintId, String status) {
    return complaints.doc(complaintId).update({
      'status': status,
    });
  }

  /// Update specific feedback by feedbackId
  Future<void> updateFeedback({
    required String complaintId,
    required String feedbackId,
    int? timeliness,
    int? effectiveness,
    int? communication,
    String? comments,
  }) {
    Map<String, dynamic> updateData = {};
    if (timeliness != null) updateData['timeliness'] = timeliness;
    if (effectiveness != null) updateData['effectiveness'] = effectiveness;
    if (communication != null) updateData['communication'] = communication;
    if (comments != null) updateData['comments'] = comments;

    return feedback(complaintId).doc(feedbackId).update(updateData);
  }




  // Get complaints by department (for department-specific admin)
  Stream<QuerySnapshot> getComplaintsForAdmin(String department) {
    return complaints.where('dept_name', isEqualTo: department).snapshots();
  }

  Stream<QuerySnapshot> getComplaintsByUserEmail(String email) {
    return _firestore
        .collection('complaints')
        .where('email', isEqualTo: email)
        .snapshots();
  }

  // Check if the logged-in user is an admin
  Future<bool> isAdmin() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot adminDoc = await users.doc(currentUser.uid).get();
      return adminDoc.exists && adminDoc['role'] == 'admin';
    }
    return false;
  }

  // Get admin's department
  Future<String> getAdminDepartment() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot adminDoc = await users.doc(currentUser.uid).get();
      return adminDoc['department'];
    }
    return '';
  }


}
