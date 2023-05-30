import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class VariableProvider with ChangeNotifier {
  String? groupName;
  String? _selectedGroupName;
  String get selectedGroupName => _selectedGroupName!;
  bool _isPressed = false;
  bool get isPressed => _isPressed;

  void setGroupName(String groupName) {
    this.groupName = groupName;
    _selectedGroupName = groupName;
    notifyListeners();
  }

  void setWarning(bool value) {
    _isPressed = value;
    notifyListeners();
  }
  void setWarningForGroup(String groupName, bool isWarning) {
    if (_selectedGroupName == groupName) {
      _isPressed = isWarning;
      notifyListeners();
    }
  }
}