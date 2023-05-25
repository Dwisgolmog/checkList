import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VariableProvider with ChangeNotifier {
  String? groupName;

  void setGroupName(String groupName) {
    this.groupName = groupName;
    notifyListeners();
  }
}