import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class VariableProvider with ChangeNotifier {
  String? groupName; // 그룹 이름을 저장하는 변수
  String? _selectedGroupName; // 선택된 그룹 이름을 저장하는 변수
  String get selectedGroupName => _selectedGroupName!; // 선택된 그룹 이름을 반환하는 getter
  bool _isPressed = false; // 버튼 눌림 상태를 저장하는 변수
  bool get isPressed => _isPressed; // 버튼 눌림 상태를 반환하는 getter

  //그룹 이름을 설정하는 메서드
  void setGroupName(String groupName) {
    this.groupName = groupName; // groupName 변수 업데이트
    _selectedGroupName = groupName; // _selectedGroupName 변수 업데이트
    notifyListeners(); // 상태 변경 알림
  }

  //경고 상태를 설정하는 메서드
  void setWarning(bool value) {
    _isPressed = value; // _isPressed 변수 업데이트
    notifyListeners(); // 상태 변경 알림
  }

  //특정 그룹에 대한 경고 상태를 설정하는 메서드
  void setWarningForGroup(String groupName, bool isWarning) {
    if (_selectedGroupName == groupName) {
      _isPressed = isWarning; // _isPressed 변수 업데이트
      notifyListeners(); //상태 변경 알림
    }
  }
}