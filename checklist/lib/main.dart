import 'package:flutter/material.dart';
import 'package:checklist/loginscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{

  //파이어베이스를 사용하기 위해 메인메소드 내에서 비동기 방식으로 아래의 메서드를 불러와야함
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'checkList',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: LoginSignup(),
    );
  }
}
