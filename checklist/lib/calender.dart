import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}
class _CalendarState extends State<Calendar>{
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('Images/cute.png'),
              radius: 60.0,
            ),
            SizedBox(
              width: 10.0,
            ),
            Text('닉닉네네임임',
                style: TextStyle(
                  fontSize: 28.0,
                )
            ),
          ],
        ),
        Divider(
          height: 60.0,
          color: Colors.black,
          thickness: 0.5,
          // endIndent: 30.0,
        ),
        TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime(2023, 5, 1),
          lastDay: DateTime(2023, 5, 31),
        ),
        Divider(
          height: 60.0,
          color: Colors.black,
          thickness: 0.5,
          // endIndent: 30.0,
        ),
        Text('리스트를 추가하시오.'),
      ]
    );
  }
}