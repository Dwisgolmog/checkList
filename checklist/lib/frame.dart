import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:checklist/calender.dart';
import 'package:checklist/homePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FramePage());
}*/

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
            //변경해야 함
            currentAccountPicture: CircleAvatar(
              /*backgroundImage: AssetImage('images/profile.png'),*/
            ),
            accountName: FutureBuilder<User?>( //현재 사용자의 아이디, 닉네임 받아오기
              future: FirebaseAuth.instance.authStateChanges().first,
              builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('로딩 중...');
                }
                if (snapshot.hasError) {
                  return Text('에러: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Text('사용자 없음');
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(snapshot.data!.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('로딩 중...');
                    }
                    if (snapshot.hasError) {
                      return Text('에러: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Text('사용자 데이터 없음');
                    }

                    Map<String, dynamic>? userData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    if (userData == null) {
                      return Text('사용자 데이터 없음');
                    }
                    String accountId = userData['accountId'];
                    String nickname = userData['nickname'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$accountId', style: TextStyle(fontSize: 16)),
                        Text('$nickname', style: TextStyle(fontSize: 14)),
                      ],
                    );
                  },
                );
              },
            ),
            accountEmail: Text(''),
          ),
          /*ListTile(
            leading: Icon(Icons.settings),
            title: Text('Setting'),
            onTap: () {},
          )*/ //굳이 넣을게 없어서 없애거나 추가할게 있으면 추가할 예정
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
