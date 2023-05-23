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
  List<bool?> itemCheckedList = []; //체크박스가 있는 리스트 아이템들의 체크 여부 관리하는 리스트

  //현재 달력에서 선택된 날짜
  DateTime selectedDay = DateTime(
    //DateTime.now() 생성자로 현재 년,월,일로 초기화
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now(); //현재 달력에서 초점이 맞춰진 날짜
  Map<DateTime, List<String>> eventList = {}; //날짜와 해당 날짜에 연결된 문자열 리스트를 관리하기 위한 맵

  @override
  //해당 위젯이 제거되기 전에 호출되는 생명주기 메서드
  void dispose() {
    //텍스트 입력 필드의 컨트롤러 해제
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
          //달력 생성 함수
          TableCalendar(
            locale: 'ko_KR', //달력의 언어와 지역 설정
            focusedDay: DateTime.now(), //초기에 포커스를 가진 날짜 설정 (현재 날짜 설정)
            firstDay: DateTime(2013, 5, 1), //달력의 시작 날짜 설정
            lastDay: DateTime(2033, 5, 31), //달력의 마지막 날짜 설정
            //헤더 제목의 텍스트 스타일 설정
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
            //날짜가 선택되었을 때 호출되는 콜백 함수
            onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
              setState(() {
                this.selectedDay = selectedDay;
                this.focusedDay = focusedDay;
              });
            },
            //클릭된 날짜 스타일 적용
            selectedDayPredicate: (DateTime day) {
              return isSameDay(selectedDay, day);
            },
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
              //// 'events' 컬렉션에서 선택된 날짜에 해당하는 문서의 변경 사항을 실시간으로 수신하는 스트림
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
                List<dynamic>? eventData =
                (snapshot.data!.data() as Map<String, dynamic>)['data'];
                if (eventData == null) {
                  eventData = [];
                }
                // 체크박스 리스트의 길이가 이벤트 데이터의 길이보다 작을 경우
                if (itemCheckedList.length < eventData.length) {
                  // 체크박스 리스트를 이벤트 데이터의 길이에 맞게 생성
                  itemCheckedList =
                      List.generate(eventData.length, (_) => false);
                }
                // 이벤트 데이터를 기반으로 리스트뷰를 생성하여 반환
                return ListView.builder(
                  itemCount: eventData.length,
                  itemBuilder: (context, index) {
                    // 각 이벤트 아이템을 ListTile로 표시
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
                            //이벤트 데이터 리스트에서 현재 인덱스에 해당하는 값을 가져옴
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
                            //체크박스를 생성하고 체크 여부를 관리
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
                  //텍스트 입력 값 관리
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: '할 일',
                  ),
                ),
                actions: [
                  Row(
                    //자식 위젯들 사이에 동일한 간격을 유지하면서 공간을 고르게 분배하는 정렬 방식
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
                            //선택된 날짜에 대한 이벤트 리스트가 없는 경우 새로 생성
                            if (eventList[selectedDay] == null) {
                              eventList[selectedDay] = [];
                            }
                            //입력된 텍스트를 이벤트 리스트에 추가
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
  //State 객체가 의존성이 변경되었을 때 호출 되는 메서드
  void didChangeDependencies() {
    super.didChangeDependencies();
    //날짜 형식을 지역화 하기 위해 필요한 초기화 작업을 수행하는 함수
    initializeDateFormatting(Localizations.localeOf(context).languageCode);
  }
}
