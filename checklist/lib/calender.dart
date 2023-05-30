import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checklist/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now(); //현재 달력 위젯에서 포커스된 날짜(오늘 날짜)
  DateTime? _selectedDay; //사용자가 선택한 날짜
  TextEditingController tec = TextEditingController(); //TextField에서 사용자가 입력한 내용
  final firestoreInstance = FirebaseFirestore.instance; //Firestore 데이터베이스에 접근하기 위한 인스턴스
  String groupName = ""; //클릭한 그룹의 이름
  DocumentSnapshot<Map<String, dynamic>>? documentSnapshot; //문서id
  bool _isLoading = true; //로딩 중인지 나타내는 변수
  ImageProvider<Object>? _userImageProvider; //현재 로그인한 사용자의 이미지를 나타내는 변수
  bool isPressed = false; //눌렸는지 나타내는 변수

  void onPressedFunction() { //눌렀을 때 상태 변하는 함수
    setState(() {
      isPressed = true; // 아이콘을 바꾸기 위해 상태 변경
      String selectedGroupName = Provider.of<VariableProvider>(context, listen: false).selectedGroupName;
      Provider.of<VariableProvider>(context, listen: false).setWarningForGroup(selectedGroupName, true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //groupName 변수 값을 Firestore의 groupName 필드 값으로 초기화 함
    groupName = Provider.of<VariableProvider>(context).groupName ?? '';
    fetchData();
    _getUserImage();
  }

  //문서id 찾는 함수
  Future<void> fetchData() async {
    //Firestore에서 'Group' 컬렉션에서 'GroupName' 필드 값이 groupName과 일치하는 문서를 가져옴
    documentSnapshot = await firestoreInstance
        .collection('Group')
        .where('GroupName', isEqualTo: groupName)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first; //가져온 문서 중 첫 번째 문서를 반환
      }
      return null; //문서가 없으면 null 반환
    });
    //데이터 로딩이 완료되었음을 나타내는 _isLoading 변수를 false로 설정
    setState(() {
      _isLoading = false;
    });
  }

  //데이터를 저장하는 함수
  Future<void> setData(DateTime day) async {
    if (documentSnapshot != null) {
      String documentId = documentSnapshot!.id;

      //Firestroe에 선택한 날짜에 대한 데이터를 저장
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
          //documentSnapshot에 해당 날짜의 데이터가 이미 있는지 확인
          if (documentSnapshot!.data()!.containsKey(day.toString())) {
            items = List<Map<String, dynamic>>.from(
              documentSnapshot!.data()![day.toString()]['Items'] ?? [],
            );
          }
          //새로운 할 일을 items 리스트에 추가
          items.add({'Text': tec.text, 'isChecked': false});
          documentSnapshot!.data()![day.toString()] = {'Items': items};
        });
      });
    } else {
      print('해당 필드 값이 있는 위치를 찾을 수 없습니다.');
    }
  }

  //할 일을 입력받는 다이얼로그 표시
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,//버튼 간격 띄움
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

  //현재 로그인 한 사용자의 이미지 가져오는 함수
  Future<void> _getUserImage() async {
    User? user = FirebaseAuth.instance.currentUser;

    //현재 사용자가 로그인 한 경우
    if (user != null) {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('user').doc(user.uid).get();

      //사용자 문서가 존재하는 경우
      if (userSnapshot.exists) {
        String userImage = userSnapshot.get('picked_image') ?? '';

        setState(() {
          //사용자 이미지가 있는 경우
          if (userImage != '') {
            _userImageProvider = NetworkImage(userImage) as ImageProvider<Object>?;
          } else { //사용자 이미지가 없는 경우
            _userImageProvider = null;
          }
        });
      } else {
        print('사용자 문서가 존재하지 않습니다.');
      }
    } else {
      print('사용자가 인증되지 않았습니다.');
    }
  }
  @override
  Widget build(BuildContext context) {
    groupName = Provider.of<VariableProvider>(context).groupName ?? '';
    return Scaffold(
      body: Column(
        children: [
          //table-calendar API
          TableCalendar(
            locale: 'ko_KR', //달력 언어
            firstDay: DateTime.utc(2013, 1, 1), //달력 시작 날짜
            lastDay: DateTime.utc(2033, 1, 1), //달력 마지막 날짜
            focusedDay: _focusedDay, //현재 포커스된 날짜
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day); //선택된 날짜와 현재 날짜가 동일한지 확인
            },
            onDaySelected: (selectedDay, focusedDay) async {
              setState(() {
                _selectedDay = selectedDay; //선택된 날짜를 업데이트 하여 상태를 변경
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay; //페이지가 변경되었을 때 포커스된 날짜를 업데이트
              });
            },

            //달력 제목의 텍스트 스타일 설정
            headerStyle: HeaderStyle(
              titleCentered: true, //달력 제목을 가운데로 정렬
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMMd(locale).format(date), //달력 제목의 텍스트 형식을 지정
              formatButtonVisible: false, //달력 포맷 변경 버튼을 숨김
              titleTextStyle: const TextStyle(
                fontSize: 20.0,
                color: Colors.blue,
              ),
            ),

            //달력의 텍스트 스타일 변경
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false, //현재 월 이외의 날짜 숨김
              weekendTextStyle: TextStyle(color: Colors.red), //주말의 텍스트 스타일 변경
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
                ? Center(child: CircularProgressIndicator()) //데이터를 로딩 중인 경우 로딩 표시기 표시
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: firestoreInstance
                  .collection("Group")
                  .doc(documentSnapshot?.id)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                  snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // 연결이 대기 중인 경우 로딩 표시기를 표시
                }
                if (snapshot.hasError) {
                  return Text('오류: ${snapshot.error}'); // 오류가 발생한 경우 오류 메시지를 표시
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('');
                }
                var data = snapshot.data!.data();
                List<Map<String, dynamic>> items = [];
                if (_selectedDay != null &&
                    data!.containsKey(_selectedDay.toString()))
                { // 선택된 날짜의 데이터를 가져옴
                  Map<String, dynamic> retrievedData =
                  data[_selectedDay.toString()];
                  items = List<Map<String, dynamic>>.from(
                      retrievedData['Items'] ?? []); // 해당 날짜의 아이템 목록을 가져옴
                }
                return ListView.builder(
                  itemCount: items.length, // 아이템 개수를 지정
                  itemBuilder: (BuildContext context, int index) {
                    String text = items[index]['Text']; // 현재 인덱스에 해당하는 아이템의 텍스트를 가져옴
                    bool? isChecked = items[index]['isChecked'] ?? false; // 현재 인덱스에 해당하는 아이템의 체크 여부를 가져옴
                    return ListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            radius: 60.0,
                            backgroundImage: _userImageProvider ??
                                AssetImage('assets/placeholder.png'),// 사용자 이미지 또는 기본 이미지를 표시
                          ),
                          SizedBox(width: 15.0),
                          Expanded(child: Text(text)), // 아이템 텍스트를 표시
                          TextButton(
                            style: ButtonStyle(
                              textStyle:
                              MaterialStateProperty.all<TextStyle>(
                                TextStyle(
                                    decoration:
                                    TextDecoration.underline), // 밑줄이 있는 텍스트 스타일을 적용
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
                            value: isChecked, // 체크 여부를 설정
                            onChanged: (value) {
                              setState(() {
                                isChecked = value; // 체크 상태를 업데이트
                                items[index]['isChecked'] = isChecked; //아이템의 체크 상태를 업데이트
                                firestoreInstance
                                    .collection("Group")
                                    .doc(documentSnapshot!.id.toString())
                                    .set({
                                  _selectedDay.toString(): {
                                    'Items': items,
                                  }
                                },
                                    SetOptions(merge: true)); // Firestore에 업데이트된 아이템 목록을 저장
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
          if (groupName.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('선택된 그룹이 없습니다.')),
            );
          } else {
            popupwindow();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
