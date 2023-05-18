import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget{
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage>{
  List<String> groups = []; //그룹 리스트
  TextEditingController groupNameController = TextEditingController();

  void addGroup(){
    String groupName = groupNameController.text;
    if(groupName.isNotEmpty){
      setState(() {
        groups.add(groupName); //사용자가 입력한 그룹 이름을 리스트에 추가
        groupNameController.clear(); //텍스트 필드 초기화
      });
    }
  }

  void deleteGroup(int index) {
    setState(() {
      groups.removeAt(index); // 그룹 삭제
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index){
            return Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                    children: [
                      Expanded(
                        child: Text(groups[index], style: TextStyle(fontSize: 20)),
                      ),
                      IconButton(
                        onPressed: () {
                          // 그룹 오른쪽 버튼 클릭 시 동작할 코드 작성
                        },
                        icon: Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () {
                          deleteGroup(index);
                        },
                        icon: Icon(Icons.delete),
                      ),
                  ],
                ),
              ),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add),
        onPressed: (){
          showDialog(
              context: context,
              builder: (BuildContext context){
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
                        onPressed:() {
                          Navigator.pop(context); //다이얼로그 닫기
                          addGroup(); //그룹 추가 함수 호출
                        },
                      child: Text('추가'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);// 다이얼로그 닫기
                        groupNameController.clear();
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