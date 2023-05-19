import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//DateFormat.yMMMMd(locale).format(date)
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  TextEditingController _textEditingController = TextEditingController();
  List<bool> itemCheckedList=[];
  List<String> lists = [];

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        children: <Widget>[
          TableCalendar(
              locale: 'ko_KR',
              focusedDay: DateTime.now(),
              firstDay: DateTime(2013, 5, 1),
              lastDay: DateTime(2033, 5, 31),
              headerStyle: HeaderStyle(
                titleCentered: true,
                //title 중앙 정렬 여부
                titleTextFormatter: (date, locale) =>
                    DateFormat.yMMMMd(locale).format(date),
                //title의 날짜 형태
                formatButtonVisible: false,
                //formatButton 노출 여부(2weeks)
                titleTextStyle: const TextStyle(
                  //title 글자 꾸미기
                  fontSize: 20.0,
                  color: Colors.blue,
                ),
              ),
              onDaySelected: (DateTime selectedDay, DateTime focusedDay){
                //  선택된 날짜의 상태를 갱신
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
              },
              selectedDayPredicate: (DateTime day){
                return isSameDay(selectedDay, day);
              }
          ),
          Divider(
            height: 60.0,
            color: Colors.black,
            thickness: 0.5,
          ),
          Text('Add a list.'),
          SizedBox(height: 16.0), // Adds some space below the text
          Expanded(
            child: ListView.builder(
              itemCount: lists.length,
              itemBuilder: (context, index) {
                if(itemCheckedList.length<lists.length){
                  itemCheckedList.add(false);
                }
                return ListTile(
                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('Images/cute.png'),
                        radius: 60.0,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Expanded(
                        child: Text(lists[index]),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        onPressed: (){},
                        child: Text('재촉하기'),
                      ),
                      Checkbox(
                          value: itemCheckedList[index],
                          onChanged: (value){
                            setState(() {
                              itemCheckedList[index] = value!;
                            });
                          }
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Dialog'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('리스트를 추가하세요.'),
                content: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: '할 일',
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        child: Text('취소'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text('확인'),
                        onPressed: () {
                          setState(() {
                            lists.add(_textEditingController.text);
                            _textEditingController.clear();
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}