import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  TextEditingController groupNameController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser; //로그인한 유저의 정보를 가져오는 변수
  int groupCount = 0; // 그룹 개수를 저장할 변수
  List<String>? groupNames = [];

  @override
  void initState() {
    super.initState();
    getGroupList().then((_) {
      // 비동기 작업이 완료되었을 때 build() 메소드 호출
      setState(() {});
    });
  }

  //플러팅 버튼 추가 버튼을 눌렀을시  1:Group 컬렉션을 생성하여 그룹이름을 저장
  //                          2:로그인한 유저에 list 컬렉션을 생성하여 생성한 그룹 ID 추가
  Future<void> addGroup() async {
    String groupName = groupNameController.text;
    if (groupName.isNotEmpty) {
      try {
        //새로운 그룹 리스트 생성
        CollectionReference groupCollection = FirebaseFirestore.instance.collection('Group');
        DocumentReference newDocumentRef = await groupCollection.add({
          'GroupName':groupName,
        });
        print('====================');

        //로그인한 유저를 참조하여 새로운 list라는 컬렉션을 추가하고 거기에 그룹ID를 저장
        CollectionReference usersRef =
        FirebaseFirestore.instance.collection('user');
        CollectionReference listCollection = usersRef.doc(user!.uid).collection('list');
        DocumentReference newDocumentRef2 = await listCollection.add({
          'GroupID': newDocumentRef.id,
        });

        getGroupList(); //추가 버튼 누른후 재로딩
        groupNameController.clear(); // 텍스트 필드 초기화

      } catch (e) {
        print('Error adding group: $e');
      }
    }
  }

  //inviteGroup 마저 수정 예정
  //그룹원을 초대하기 위해 다이얼로그를 표시하는 역할
  //   void inviteGroup(int index) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         String memberId = ''; // 초대할 그룹원을 저장하는 변수
  //
  //         return AlertDialog(
  //           title: Text('그룹원 초대'),
  //           content: TextField(
  //             onChanged: (value) {
  //               memberId = value; // 입력된 그룹원을 변수에 저장
  //             },
  //             decoration: InputDecoration(
  //               hintText: '그룹원 아이디',
  //             ),
  //           ),
  //           actions: [
  //             ElevatedButton(
  //               onPressed: () {
  //                 // 초대 동작 처리
  //                 // String groupId = groups[index].id;
  //                 // inviteMember(groupId, memberId);
  //
  //                 Navigator.pop(context); // 다이얼로그 닫기
  //               },
  //               child: Text('초대'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Navigator.pop(context); // 다이얼로그 닫기
  //               },
  //               child: Text('취소'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }

  //그룹 추가 버튼
  // void inviteMember(String groupId, String memberId) { ≈
  //   try {
  //     CollectionReference groupsRef =
  //     FirebaseFirestore.instance.collection('groups');
  //     // 초대할 그룹원의 정보를 업데이트하는 작업 수행
  //     groupsRef.doc(groupId).update({
  //       'invitedMembers': FieldValue.arrayUnion([memberId]),
  //     });
  //     print('그룹원을 성공적으로 초대했습니다.');
  //   } catch (e) {
  //     print('그룹원 초대 동작에 실패했습니다: $e');
  //   }
  // }

  //클릭한 카드(그룹)을 삭제하는 메소드
  Future<void> deleteGroup(String groupId) async {
    try {
      //클릭한 카드의 정보가 담긴 그룹 데이터베이스의 문서 Id를 가져옴
      CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('Group');
      QuerySnapshot querySnapshot1 =
      await groupCollection.where('GroupName', isEqualTo: groupId).get();
      String documentId = querySnapshot1.docs[0].id;

      //로그인한 유저의 list를 참조
      CollectionReference usersRef = FirebaseFirestore.instance.collection('user');
      CollectionReference listCollection = usersRef.doc(user!.uid).collection('list');

      //클릭한 카드의 정보가 담긴 유저의 list를 가져옴
      QuerySnapshot querySnapshot2 =
      await listCollection.where('GroupID', isEqualTo: documentId).get();

      //삭제하기
      await groupCollection.doc(documentId).delete();
      await listCollection.doc(querySnapshot2.docs[0].id).delete();

      //재로딩
      setState(() {
        getGroupList();
      });
    } catch (e) {
      print('Error deleting group: $e');
    }
  }

  //로그인한 유저가 가지고있는 GroupID목록을 가져옴
  Future<void> getGroupList() async{
    try{
      //groupNames 재 초기화
      groupNames = [];

      // Group, user 컬렉션 참조
      CollectionReference groupCollection = FirebaseFirestore.instance.collection('Group');
      CollectionReference userCollection = FirebaseFirestore.instance.collection('user');

      // 로그인한 사용자의 문서를 참조하여 해당 문서의 list라는 컬렉션의 GroupID값을 가져오기
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await userCollection.doc(userId).get();
      QuerySnapshot listSnapshot = await userDoc.reference.collection('list').get();

      //user가 가지고있는 그룹ID와 Group의 문서 아이디를 비교하여 같은것을 저장
      await Future.wait(listSnapshot.docs.map((listDoc) async{
        String groupId = listDoc.get('GroupID');
        print('GroupID: $groupId');

        QuerySnapshot querySnapshot = await groupCollection.where(FieldPath.documentId, isEqualTo: groupId).get();

        if (querySnapshot.docs.isNotEmpty) {
          // 그룹 문서의 GroupName 필드 값을 가져와서 groupNames 리스트에 추가
          String groupName = querySnapshot.docs[0].get('GroupName');
          groupNames!.add(groupName);
        }
      }));
    } catch(e){
      print('Error getGroupList: $e');
    }

    groupCount = groupNames!.length;
    setState(() {
      this.groupNames = groupNames;
    });
    print('groupNames:');
    print(groupNames);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: ListView.builder ( //그룹 추가 ui
        itemCount: groupCount,
        itemBuilder: (context, index) {
          if (index == groupCount) { //수정 필요
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
                          Text(groupNames![index], style: TextStyle(fontSize: 20)),
                    ),
                    IconButton(
                      onPressed: () {
                        //inviteGroup(index);
                      },
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {
                        deleteGroup(groupNames![index] as String);
                        print(groupNames![index]);
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

      //그룹 추가 버튼
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        //다이아로그 위젯을 보여주게함
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
                  //추가버튼
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 다이얼로그 닫기
                      addGroup(); // 그룹 추가 함수 호출
                    },
                    child: Text('추가'),
                  ),
                  //취소 버튼
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
