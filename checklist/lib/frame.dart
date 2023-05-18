import 'package:flutter/material.dart';
import 'package:checklist/calender.dart';
import 'package:checklist/homePage.dart';

void main() => runApp(FramePage());

class FramePage extends StatelessWidget{
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
  State<Frame> createState(){
    return _Frame();
  }
}

class _Frame extends State<Frame>{

  int _selectedIndex = 0;
  
  List _pages = [HomePage(), Calendar()];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('CheckList', style: TextStyle(fontSize: 30))
      ),
      drawer: Drawer(
        child : ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(//변경해야 함
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('images/profile.png'),
                ),
            accountName: Text('주찬양'),
            accountEmail: Text('cksdid3357@naver.com'),
            decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0)
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.settings
              ),
              title: Text('Setting'),
              onTap: (){},
            )
          ],
        )
      ),
      body: Center(
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add),
      onPressed: (){
      }),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Dialog'
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    // state 갱신
    setState(() {
      _selectedIndex = index;
    });
  }
}


