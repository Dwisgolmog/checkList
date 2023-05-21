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
  //텍스트 필드의 변화를 핸들링
  List<bool> itemCheckedList=[];
  //체크박스 목록(상태)를 저장하는 List
  List<String> lists = [];
  //TextField에 입력된 값 저장하는 List

  DateTime selectedDay = DateTime(
    //현재 선택된 날짜
    DateTime.now().year, //현재 연도
    DateTime.now().month, //현재 월
    DateTime.now().day, //현재 일
  );
  DateTime focusedDay = DateTime.now(); //현재 날짜에 포커싱

  @override
  void dispose() {
    //컨트롤러 객체가 제거 될 때 변수에 할당 된 메모리를 해제
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
              locale: 'ko_KR', //달력 한국어
              focusedDay: DateTime.now(), // 현재 날짜 포커싱
              firstDay: DateTime(2013, 5, 1), //달력 시작 날짜
              lastDay: DateTime(2033, 5, 31), //달력 종료 날짜
              headerStyle: HeaderStyle(
                titleCentered: true,
                //title 중앙 정렬 여부
                titleTextFormatter: (date, locale) =>
                    DateFormat.yMMMMd(locale).format(date),
                //title의 날짜 형태
                formatButtonVisible: false,
                //formatButton 노출 여부(2weeks 버튼)
                titleTextStyle: const TextStyle(
                  //title 글자 꾸미기
                  fontSize: 20.0,
                  color: Colors.blue,
                ),
              ),
              onDaySelected: (DateTime selectedDay, DateTime focusedDay){
                //  선택된 날짜의 상태를 갱신
                setState(() {
                  //오브젝트 상태를 변경하기 위한 메소드
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
              },
              selectedDayPredicate: (DateTime day){
                //selectedDay와 동일한 날자의 모양 바꿈
                return isSameDay(selectedDay, day);
              }
          ),
          Divider(
            height: 60.0,
            color: Colors.black,
            thickness: 0.5,
          ),
          Text('Add a list.'),
          SizedBox(height: 16.0),
          Expanded(
            //여러 개의 '할 일' 목록을 스크롤 가능한 리스트로 표시
            child: ListView.builder(
              //리스트의 항목을 동적으로 생성하여 표시
              itemCount: lists.length, //TextField에 입력된 아이템 수
              itemBuilder: (context, index) {
                if(itemCheckedList.length<lists.length){ //체크박스의 수가 입력된 아이템 수보다 작으면
                  itemCheckedList.add(false);
                  //  아이템 수에 맞게 체크박스 초기 상태 추가
                }
                return ListTile(
                  //할 일 할목을 나타내는 위젯
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
                              //  버튼에 밑줄 style 추가
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
                    //버튼 사이의 여유 공간을 균등하게 배분
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

  //initializeDateFormatting() 함수를 호출하여 날짜 및 시간 형식을 초기화하는 것
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting(Localizations.localeOf(context).languageCode);
  }

}