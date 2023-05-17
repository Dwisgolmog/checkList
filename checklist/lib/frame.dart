import 'package:flutter/material.dart';

class Frame extends StatefulWidget {
  @override
  State<Frame> createState(){
    return _Frame();
  }
}

class _Frame extends State<Frame>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child : ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('images/profile.png'),
                ),
            accountName: Text('주찬양'),
            accountEmail: Text('cksdid3357@naver.com'),
            decoration: BoxDecoration(
                color: Colors.blue,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add),
      onPressed: (){

      }),
      bottomNavigationBar: BottomNavigationBar(
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
}


