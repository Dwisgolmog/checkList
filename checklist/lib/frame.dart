import 'dart:io';
import 'package:flutter/material.dart';
import 'package:checklist/calender.dart';
import 'package:checklist/homePage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:checklist/add_image.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FramePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'groupPage',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: Frame(),
    );
  }
}

class Frame extends StatefulWidget {
  @override
  State<Frame> createState() {
    return _Frame();
  }
}

class _Frame extends State<Frame> {
  int _selectedIndex = 0;
  List _pages = [HomePage(), Calendar()]; //바텀 네비게이터 바 눌렀을 때 화면 전환
  String _userName = ''; // 사용자 이름 저장 변수
  File? _userImage; //사용자 이미지 저장 변수
  File? userPickedImage;

  @override
  void initState() {
    super.initState();
    getUserDisplayName();
  }

  void pickedImage(File image){
    userPickedImage = image;
    setState(() {
      _userImage = image;
    });
  }

  void showAlert(BuildContext context){
    showDialog(
        context: context,
        builder: (context){
          return Dialog(
            backgroundColor: Colors.white,
            child: AddImage(pickedImage),
          );
        }
    );
  }

  //firebase에서 user컬렉션에 있는 userNamer과 picked_image를 가져오는 메소드
  Future<void> getUserDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
      if (userSnapshot.exists) {
        String username = userSnapshot.get('userName') ?? '';
        String userImage = userSnapshot.get('picked_image') ?? '';
        print('이미지 주소: $userImage');
        print('사용자 이름: $username');
        setState(() {
          _userImage = userImage != '' ? File(userImage) : null;
          _userName = username;
        });
      } else {
        print('사용자 문서가 존재하지 않습니다.');
      }
    } else {
      print('사용자가 인증되지 않았습니다.');
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar( //앱바 설정
          centerTitle: true,
          title: Text('CheckList', style: TextStyle(fontSize: 30))),
      drawer: Drawer( //사이드 메뉴(현재 사용자의 아이디랑 닉네임만 받아와서 헤더에 나타내는 느낌)
          child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundImage: _userImage != null ? FileImage(_userImage!) : null,
            ),
            accountName: Text(_userName+'님',style: TextStyle(
              fontSize: 30, color: Colors.grey[300]
            ),),
            accountEmail: Text(''),
            otherAccountsPictures: [
              IconButton(
                icon: Icon(Icons.image,color: Colors.grey[300],),
                onPressed: () {
                  setState(() {
                    showAlert(context);
                    print(_userImage);
                  });
                },
              ),
            ],
          ),
        ],
      )),
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar( //바텀 네비게이터 바
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Dialog'),
        ],
      ),
    );
  }

  void _onItemTapped(int index) { //바텀 네이게이터 바 아이템 눌렸을 때
    // state 갱신
    setState(() {
      _selectedIndex = index;
    });
  }
}
