import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; //table-calendar API
import 'package:intl/intl.dart'; //titleTextFormatter 사용
import 'package:cloud_firestore/cloud_firestore.dart';

class Calendar extends StatefulWidget {
  //Calendar 클래스 매개변수
  final String Id;
  Calendar({required this.Id});

  @override
  _CalendarState createState() => _CalendarState();
}
class _CalendarState extends State<Calendar>{
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; // 클릭한 날짜
  TextEditingController tec = TextEditingController(); // TextField의 있는 값 핸들링
  bool? isChecked = false;
  final firestoreInstance = FirebaseFirestore.instance;//firestore 인스턴스를 사용하여 데이터베이스와 상호 작용


  //firebase에 리스트 값 저장
  Future<void> setData(DateTime day) async {
    await firestoreInstance
        .collection("Group")
        .doc(widget.Id.toString())
        .set({
      day.toString(): {
        'Items': FieldValue.arrayUnion([
          {'Text': tec.text, 'isChecked': isChecked}
        ])
      }
    }, SetOptions(merge: true));
  }

  //팝업창
  Future<void>popupwindow() async{
    return showDialog<void>(
        context: context,
        barrierDismissible: true, //바깥 영역 터치시 닫을지 여부
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('리스트 생성'),
            content: TextField(
              controller: tec, //TextField에 입력된 값 tec에 저장
              decoration: InputDecoration(hintText: '할 일'),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,//자식 위젯들을 균등한 간격으로 정렬
                children: [
                  ElevatedButton(
                    child: Text('취소'),
                    onPressed: (){
                      tec.clear();
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    child: Text('확인'),
                    onPressed: (){
                      setData(_selectedDay!);
                      tec.clear();
                      Navigator.pop(context);
                    },
                  )
                ],
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      //table calendar 기본 설정
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',// 달력 형식을 한국어로 설정
            firstDay: DateTime.utc(2013, 1, 1), //달력에서 사용할 수 있는 첫 번째 날짜
            lastDay: DateTime.utc(2033,1,1), //달력에서 사용할 수 있는 마지막 날짜
            focusedDay: _focusedDay, // 현재 날짜(현재 표시되어야 하는 월)

            //day와 _selectedDay가 동일한 날짜인지 확인하는 함수
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day); //둘이 같은 날짜면 true 반환
            },
            //사용자가 날짜를 선택할 때 실행되는 이벤트 핸들러
            onDaySelected: (selectedDay, focusedDay) async {
              setState(() { //상태를 업데이트
                _selectedDay = selectedDay; //사용자가 선택한 날짜
              });
            },
            onPageChanged: (focusedDay){
              setState(() {
                _focusedDay = focusedDay;
              });
            },

            //달력 헤더 스타일 변경
            headerStyle: HeaderStyle(
              titleCentered: true, //title 중앙 정렬 여부
              //title의 날짜 형태
              titleTextFormatter: (date, locale) => DateFormat.yMMMMd(locale).format(date),
              formatButtonVisible: false, //formatButton 노출 여부
              titleTextStyle: const TextStyle(
                fontSize: 20.0,
                color: Colors.blue,
              ),
            ),

            //달력 (바디) 스타일 변경
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false, //다른 달의 날짜 노출 여부
              weekendTextStyle: TextStyle(color: Colors.red), //주말 스타일
            ),
          ),

          //구분선
          Divider(
            height: 60.0,
            color: Colors.black,
            thickness: 0.5,
          ),

          Text('Add a list.'),

          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: firestoreInstance
                  .collection("Group")
                  .doc(widget.Id.toString())
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                  snapshot) {

                //연결 상태가 대기 중이면 로딩 표시기를 중앙에 표시
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                //오류가 발생하면 요류 메시지 표시
                if (snapshot.hasError) {
                  return Text('오류: ${snapshot.error}');
                }
                // 데이터가 없거나 문서가 존재하지 않으면 빈 텍스트를 표시합니다.
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('');
                }
                var data = snapshot.data!.data(); //stream으로부터 가져온 데이터
                List<Map<String, dynamic>> items = [];

                //선택된 날짜에 해당하는 데이터가 있는지 확인
                if (_selectedDay != null && data!.containsKey(_selectedDay.toString())) {
                  //선택된 나짜에 해당하는 항목 리스트를 가져옴
                  Map<String, dynamic> retrievedData = data[_selectedDay.toString()];
                  items = List<Map<String, dynamic>>.from(retrievedData['Items'] ?? []);
                }

                return ListView.builder(
                  itemCount: items.length, //아이템의 개수는 items 리스트의 길이
                  itemBuilder: (BuildContext context, int index) {
                    //현재 인덱스에 해당하는 아이템을 가져옴
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
                                isChecked = value;
                                items[index]['isChecked'] = isChecked;
                                firestoreInstance
                                    .collection("Group")
                                    .doc(widget.Id.toString())
                                    .set({
                                  _selectedDay.toString():{
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
        onPressed: (){
          popupwindow(); //팝업창
        },
        child: Icon(Icons.add),
      ),
    );