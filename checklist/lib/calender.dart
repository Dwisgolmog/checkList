import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  TextEditingController _textEditingController = TextEditingController();
  List<bool?> itemCheckedList = [];
  List<String> lists = [];
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();
  Map<DateTime, List<String>> eventList = {};

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Firebase 초기화
    Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          TableCalendar(
            locale: 'ko_KR',
            focusedDay: DateTime.now(),
            firstDay: DateTime(2013, 5, 1),
            lastDay: DateTime(2033, 5, 31),
            headerStyle: HeaderStyle(
              titleCentered: true,
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMMd(locale).format(date),
              formatButtonVisible: false,
              titleTextStyle: const TextStyle(
                fontSize: 20.0,
                color: Colors.blue,
              ),
            ),
            onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
              setState(() {
                this.selectedDay = selectedDay;
                this.focusedDay = focusedDay;
              });
            },
            selectedDayPredicate: (DateTime day) {
              return isSameDay(selectedDay, day);
            },
          ),
          Divider(
            height: 60.0,
            color: Colors.black,
            thickness: 0.5,
          ),
          Text('Add a list.'),
          SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .doc(selectedDay.toString())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('No data'));
                }
                List<dynamic>? eventData =
                (snapshot.data!.data() as Map<String, dynamic>)['data'];
                if (eventData == null) {
                  eventData = [];
                }
                if (itemCheckedList.length < eventData.length) {
                  itemCheckedList =
                      List.generate(eventData.length, (_) => false);
                }
                return ListView.builder(
                  itemCount: eventData.length,
                  itemBuilder: (context, index) {
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
                            child: Text(eventData![index].toString()),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            onPressed: () {},
                            child: Text('재촉하기'),
                          ),
                          Checkbox(
                            value: itemCheckedList[index],
                            onChanged: (value) {
                              setState(() {
                                itemCheckedList[index] = value!;
                              });
                            },
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
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
                          setState(() {
                            _textEditingController.clear(); // 텍스트 입력 필드 초기화
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text('확인'),
                        onPressed: () {
                          setState(() {
                            if (eventList[selectedDay] == null) {
                              eventList[selectedDay] = [];
                            }
                            eventList[selectedDay]!
                                .add(_textEditingController.text);
                            _textEditingController.clear();
                          });
                          // Firestore에 데이터 업데이트
                          FirebaseFirestore.instance
                              .collection('events')
                              .doc(selectedDay.toString())
                              .set({'data': eventList[selectedDay]}, SetOptions(merge: true));
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting(Localizations.localeOf(context).languageCode);
  }
}
