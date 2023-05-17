import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Calender(),
    );
  }
}

class Calender extends StatefulWidget {
  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calender'),
      ),
      body: Column(
          children: <Widget>[
            TableCalendar(
              focusedDay: DateTime.now(),
              firstDay: DateTime(2023,5,1),
              lastDay: DateTime(2023,5,31),),
            Divider(
              height: 60.0,
              color: Colors.black,
              thickness: 0.5,
            ),
            Text('리스트를 추가하세요.'),
          ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Dialog'
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints){
                  return AlertDialog(
                    title: Text('리스트 생성'),
                    content: Container(
                      height: constraints.maxHeight * 0.3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: '할 일',
                            ),
                          ),
                          BottomNavigationBar(

                            showSelectedLabels: false,
                            showUnselectedLabels: false,
                            items: [
                              BottomNavigationBarItem(
                                icon: Text('Cancel'),
                                label: 'Cancel',
                              ),
                              BottomNavigationBarItem(
                                icon: Text('Submit'),
                                label: 'Submit',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}