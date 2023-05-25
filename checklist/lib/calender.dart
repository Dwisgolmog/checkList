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
  //텍스트 입력 필드와 상호작용하기 위한 클래스
  TextEditingController _textEditingController = TextEditingController();
  DateTime selectedDay = DateTime.now(); // 달력에서 현재 선택된 날짜
  DateTime focusedDay = DateTime.now(); // 달력이 현재 초점을 맞추고 있는 날짜
  Map<DateTime, List<String>> eventList = {}; //해당 날짜에 있는 이벤트를 나타내는 문자열의 리스트
  Map<DateTime, List<bool?>> itemCheckedList = {}; //해당 날짜의 각 이벤트 항목에 대한 체크 상태를 나타내는 리스트

  @override
  void initState() {
    super.initState();
    // Firebase 초기화
    Firebase.initializeApp();
  }

  @override
  //해당 위젯이 제거되기 전에 호출되는 생명주기 메서드
  void dispose() {
    //텍스트 입력 필드의 컨트롤러 해제
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 현재 컨텍스트의 로케일 언어 코드를 사용하여 날짜 형식 초기화
    initializeDateFormatting(Localizations.localeOf(context).languageCode);
    // 선택된 날짜에 해당하는 이벤트 데이터 가져오기
    fetchEventData(selectedDay);
  }


  void fetchEventData(DateTime day) {
    // Firestore에서 해당 날짜의 이벤트 데이터 가져오기
    FirebaseFirestore.instance
        .collection('events')
        .doc(day.toString())
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        List<dynamic>? eventData = snapshot.data()?['data'];
        List<dynamic>? checkedData = snapshot.data()?['checked'];

        setState(() {
          // 이벤트 리스트 업데이트
          eventList[day] = eventData?.map((e) => e as String)?.toList() ?? [];
          // 체크 여부 리스트 초기화
          itemCheckedList[day] =
              List.generate(eventList[day]?.length ?? 0, (_) => false);

          // Firestore의 "checked" 필드를 기반으로 체크 여부 업데이트
          for (int i = 0; i < (checkedData?.length ?? 0); i++) {
            itemCheckedList[day]![i] = checkedData?[i] as bool? ?? false;
          }
        });
      } else {
        setState(() {
          // 이벤트 리스트 초기화
          eventList[day] = [];
          // 체크 여부 리스트 초기화
          itemCheckedList[day] = [];
        });
      }
    });
  }

  void updateEventData(DateTime day, List<String>? eventData) {
    // Firestore에 이벤트 데이터 업데이트
    FirebaseFirestore.instance
        .collection('events')
        .doc(day.toString())
        .set({'data': eventData ?? []}, SetOptions(merge: true));
  }

  void updateCheckboxList(DateTime day, List<bool?>? itemCheckedList) {
    // Firestore에 체크 여부 리스트 업데이트
    FirebaseFirestore.instance
        .collection('events')
        .doc(day.toString())
        .set({'checked': itemCheckedList ?? []}, SetOptions(merge: true));
  }

  void updateCheckboxState(DateTime day, int index, bool value) {
    // 체크 여부 상태 업데이트
    itemCheckedList[day]![index] = value;
    // Firestore에 체크 여부 리스트 업데이트
    FirebaseFirestore.instance
        .collection('events')
        .doc(day.toString())
        .set({'checked': itemCheckedList[day]}, SetOptions(merge: true));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: TableCalendar(
              locale: 'ko_KR', // 한국어 로케일을 사용
              focusedDay: DateTime.now(), // 현재 날짜로 초기화
              firstDay: DateTime(2013, 5, 1), // 달력의 첫 번째 날짜를 설정
              lastDay: DateTime(2033, 5, 31), // 달력의 마지막 날짜를 설정
              headerStyle: HeaderStyle(
                titleCentered: true, // 헤더 제목을 가운데 정렬
                titleTextFormatter: (date, locale) => DateFormat.yMMMMd(locale).format(date), // 헤더 제목의 날짜 형식을 설정합니다.
                formatButtonVisible: false, // 형식 변경 버튼을 숨김.
                titleTextStyle: const TextStyle(
                  fontSize: 20.0,
                  color: Colors.blue,
                ), // 헤더 제목의 텍스트 스타일을 설정
              ),
              //날짜가 선택되었을 때 호출되는 콜백 함수
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
                fetchEventData(selectedDay); // 선택된 날짜의 이벤트 데이터를 가져옴
              },
              //클릭된 날짜 스타일 적용
              selectedDayPredicate: (DateTime day) {
                return isSameDay(selectedDay, day); // 선택된 날짜와 현재 날짜가 동일한지 확인
              },
            ),
          ),
          //달력과 리스트 구분하는 구분선
          Divider(
            height: 60.0,
            color: Colors.black,
            thickness: 0.5,
          ),
          Text('Add a list.'),
          SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              //'events' 컬렉션에서 선택된 날짜에 해당하는 문서의 변경 사항을 실시간으로 수신하는 스트림
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .doc(selectedDay.toString())
                  .snapshots(),
              builder: (context, snapshot) {
                //연결 상태 확인
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                // 스냅샷에 데이터가 없거나 문서가 존재하지 않는 경우
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('No data'));
                }
                // 스냅샷에서 데이터를 추출하여 이벤트 데이터에 할당
                List<dynamic>? eventData = (snapshot.data?.data() as Map<String, dynamic>?)?['data'];
                if (eventData == null) eventData = [];
                // 체크박스 리스트의 길이가 이벤트 데이터의 길이보다 작을 경우
                if (itemCheckedList.length < eventData.length) {
                  itemCheckedList = Map<DateTime, List<bool?>>.from(itemCheckedList);
                  itemCheckedList[selectedDay] = List.generate(eventData.length, (_) => false);
                }//체크박스 리스트에 해당하는 날짜에 새로운 항목을 추가하고, 해당 항목을 false로 초기화
                return ListView.builder(
                  itemCount: eventData.length,
                  itemBuilder: (context, index) {
                    bool isChecked = itemCheckedList[selectedDay]![index] ?? false;
                    return ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(radius: 60.0),
                          SizedBox(width: 15.0),
                          Expanded(
                            child: Text(
                              eventData![index]?.toString() ?? '',
                            ),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                TextStyle(decoration: TextDecoration.underline),
                              ),
                            ),
                            onPressed: () {},
                            child: Text('재촉하기'),
                          ),
                          Checkbox(
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                itemCheckedList[selectedDay]![index] = value!;
                                updateCheckboxState(selectedDay, index, value);
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
                  decoration: InputDecoration(hintText: '할 일'),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        child: Text('취소'),
                        onPressed: () {
                          setState(() => _textEditingController.clear());
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text('확인'),
                        onPressed: () {
                          setState(() {
                            // 선택된 날짜에 해당하는 이벤트 리스트와 체크 여부 리스트를 초기화
                            eventList[selectedDay] ??= [];
                            itemCheckedList[selectedDay] ??= [];

                            // 텍스트 입력 필드의 값을 이벤트 리스트에 추가
                            eventList[selectedDay]!.add(_textEditingController.text);

                            // 새로운 이벤트에 대한 체크 여부를 false로 설정
                            itemCheckedList[selectedDay]!.add(false);

                            // 텍스트 입력 필드를 초기화
                            _textEditingController.clear();

                            // Firestore에 이벤트 데이터와 체크 여부 리스트를 업데이트
                            updateEventData(selectedDay, eventList[selectedDay]);
                            updateCheckboxList(selectedDay, itemCheckedList[selectedDay]);
                          });
                          // 다이얼로그 닫음
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
