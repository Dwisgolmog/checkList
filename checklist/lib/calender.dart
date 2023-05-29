import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checklist/provider.dart';
import 'package:checklist/homePage.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TextEditingController tec = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;
  String groupName = "";
  DocumentSnapshot<Map<String, dynamic>>? documentSnapshot;
  bool _isLoading = true;
  bool isPressed = false;

  void onPressedFunction() {
    setState(() {
      isPressed = true; // 아이콘을 표시하기 위해 상태 변경
      String selectedGroupName = Provider.of<VariableProvider>(context, listen: false).selectedGroupName;
      Provider.of<VariableProvider>(context, listen: false).setWarningForGroup(selectedGroupName, true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    groupName = Provider.of<VariableProvider>(context).groupName ?? '';
    fetchData();
  }

  Future<void> fetchData() async {
    documentSnapshot = await firestoreInstance
        .collection('Group')
        .where('GroupName', isEqualTo: groupName)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      }
      return null;
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> setData(DateTime day) async {
    if (documentSnapshot != null) {
      String documentId = documentSnapshot!.id;

      await firestoreInstance
          .collection('Group')
          .doc(documentId)
          .set({
        day.toString(): {
          'Items': FieldValue.arrayUnion([
            {'Text': tec.text, 'isChecked': false}
          ])
        }
      }, SetOptions(merge: true)).then((_) {
        setState(() {
          List<Map<String, dynamic>> items = [];
          if (documentSnapshot!.data()!.containsKey(day.toString())) {
            items = List<Map<String, dynamic>>.from(
              documentSnapshot!.data()![day.toString()]['Items'] ?? [],
            );
          }
          items.add({'Text': tec.text, 'isChecked': false});
          documentSnapshot!.data()![day.toString()] = {'Items': items};
        });
      });
    } else {
      print('해당 필드 값이 있는 위치를 찾을 수 없습니다.');
    }
  }

  Future<void> popupwindow() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('리스트 생성'),
          content: TextField(
            controller: tec,
            decoration: InputDecoration(hintText: '할 일'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text('취소'),
                  onPressed: () {
                    tec.clear();
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: Text('확인'),
                  onPressed: () {
                    setData(_selectedDay!);
                    tec.clear();
                    Navigator.pop(context);
                  },
                )
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    groupName = Provider.of<VariableProvider>(context).groupName ?? '';
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2013, 1, 1),
            lastDay: DateTime.utc(2033, 1, 1),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) async {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
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
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red),
            ),
          ),
          Divider(
            height: 60.0,
            color: Colors.black,
            thickness: 0.5,
          ),
          Text('Add a list.'),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: firestoreInstance
                  .collection("Group")
                  .doc(documentSnapshot?.id)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                  snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('오류: ${snapshot.error}');
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('');
                }
                var data = snapshot.data!.data();
                List<Map<String, dynamic>> items = [];
                if (_selectedDay != null &&
                    data!.containsKey(_selectedDay.toString())) {
                  Map<String, dynamic> retrievedData =
                  data[_selectedDay.toString()];
                  items = List<Map<String, dynamic>>.from(
                      retrievedData['Items'] ?? []);
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    String text = items[index]['Text'];
                    bool? isChecked = items[index]['isChecked'] ?? false;
                    return ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(radius: 60.0),
                          SizedBox(width: 15.0),
                          Expanded(child: Text(text)),
                          TextButton(
                            style: ButtonStyle(
                              textStyle:
                              MaterialStateProperty.all<TextStyle>(
                                TextStyle(
                                    decoration:
                                    TextDecoration.underline),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                onPressedFunction();
                              });
                            },
                            child: Text('재촉하기'),
                          ),
                          Checkbox(
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value;
                                items[index]['isChecked'] = isChecked;
                                firestoreInstance
                                    .collection("Group")
                                    .doc(documentSnapshot!.id.toString())
                                    .set({
                                  _selectedDay.toString(): {
                                    'Items': items,
                                  }
                                },
                                    SetOptions(merge: true));
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
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popupwindow();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
