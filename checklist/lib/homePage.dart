import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class Group {
  final String id;
  final String name;
  final String createdBy;

  Group({required this.id, required this.name, required this.createdBy});
}

class _HomePage extends State<HomePage> {
  List<String> groups = []; //그룹 리스트
  TextEditingController groupNameController = TextEditingController();
  late String currentUserID; //현재 로그인한 사용자

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        currentUserID = user as String;
      });
    });
  }

  Future<void> addGroup() async {
    String groupName = groupNameController.text;
    if (groupName.isNotEmpty) {
      try {
        CollectionReference groupsRef =
            FirebaseFirestore.instance.collection('groups');
        DocumentReference docRef = await groupsRef.add({
          'name': groupName,
          'createdBy': currentUserID,
        });
        String groupId = docRef.id;
        setState(() {
          groups.add(Group(id: groupId, name: groupName, createdBy: currentUserID) as String);
        });
        groupNameController.clear(); // 텍스트 필드 초기화
      } catch (e) {
        print('Error adding group: $e');
      }
    }
  }

  //inviteGroup 마저 수정 예정
    void inviteGroup(int index) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String invitedMember = ''; // 초대할 그룹원을 저장하는 변수

          return AlertDialog(
            title: Text('그룹원 초대'),
            content: TextField(
              onChanged: (value) {
                invitedMember = value; // 입력된 그룹원을 변수에 저장
              },
              decoration: InputDecoration(
                hintText: '그룹원 아이디',
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // 초대 동작 처리
                  inviteMember();

                  Navigator.pop(context); // 다이얼로그 닫기
                },
                child: Text('초대'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                },
                child: Text('취소'),
              ),
            ],
          );
        },
      );
    }

  void inviteMember(String groupId, String memberId) {
    try {
      CollectionReference groupsRef =
      FirebaseFirestore.instance.collection('groups');
      // 초대할 그룹원의 정보를 업데이트하는 작업 수행
      groupsRef.doc(groupId).update({
        'invitedMembers': FieldValue.arrayUnion([memberId]),
      });
      print('그룹원을 성공적으로 초대했습니다.');
    } catch (e) {
      print('그룹원 초대 동작에 실패했습니다: $e');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      CollectionReference groupsRef =
          FirebaseFirestore.instance.collection('groups');
      await groupsRef.doc(groupId).delete();
      setState(() {
        groups.removeWhere((group) => group == groupId);
      });
    } catch (e) {
      print('Error deleting group: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: groups.length + 1,
        itemBuilder: (context, index) {
          if (index == groups.length) {
            return Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('그룹을 추가하세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                ),
              ),
            );
          } else {
            return Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          Text(groups[index], style: TextStyle(fontSize: 20)),
                    ),
                    IconButton(
                      onPressed: () {
                        inviteGroup(index);
                      },
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {
                        deleteGroup(groups[index]);
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('그룹 생성'),
                content: TextField(
                  controller: groupNameController,
                  decoration: InputDecoration(
                    hintText: '그룹 이름',
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 다이얼로그 닫기
                      addGroup(); // 그룹 추가 함수 호출
                    },
                    child: Text('추가'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 다이얼로그 닫기
                    },
                    child: Text('취소'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
