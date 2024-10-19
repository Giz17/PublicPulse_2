import 'package:flutter/foundation.dart';

class ComplaintState with ChangeNotifier {
  String _complaintId = '';

  String get complaintId => _complaintId;

  void setComplaintId(String id) {
    _complaintId = id;
    notifyListeners(); // Notify listeners to update UI
  }
}
