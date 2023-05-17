import 'package:flutter/material.dart';
import 'package:checklist/frame.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginSignup extends StatefulWidget {
  const LoginSignup({Key? key}) : super(key: key);

  @override
  State<LoginSignup> createState() => _LoginSignupState();
}

class _LoginSignupState extends State<LoginSignup> {
  final _authentication = FirebaseAuth.instance;

  bool isSignup = true; //메뉴 선택시(Login or Singup)판단하기 위한 변수
  final _formKey = GlobalKey<FormState>();
  String userID = '';
  String userPassword = '';
  String userName = '';

  void _tryValidation(){
    final isValid = _formKey.currentState!.validate();
    if(isValid){
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      //앱바 생성
      appBar: AppBar(
        title: Text('Check List'),
        centerTitle: true,
      ),
      //로그인 창 생성
      body: GestureDetector(
        //화면의 다른곳을 터치하였을대 포커스를 잃게함
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeIn,
            //컨테이너 박스 관련 스타일 지정
            padding: EdgeInsets.all(20),
            height: isSignup ? MediaQuery.of(context).size.height - 320
                : MediaQuery.of(context).size.height - 400,
            width: MediaQuery.of(context).size.width - 40, //위젯의 넓이 - 40
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),

            child: SingleChildScrollView(
              child: Column(
                children:[
                  Row( //상단의 login과 sigup 생성
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //login 텍스트
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            isSignup = false;
                          });
                        },
                        child: Column(
                          children: [
                             Text('LOGIN',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: !isSignup ? Colors.black : Colors.grey, //선택한 글씨에 따른 스타일 변경
                              ),
                            ),
                            if(!isSignup)
                            Container( //글씨 밑에 밑줄 생성
                              height: 4,
                              width: 90,
                              color: Colors.yellow,
                            )
                          ],
                        ),
                      ),

                      //signup 텍스트
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            isSignup = true;
                          });
                        },
                        child: Column(
                          children: [
                            Text('SINGUP',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: isSignup ? Colors.black : Colors.grey,
                              ),
                            ),
                            if(isSignup)
                            Container( //글씨 밑에 밑줄 생성
                              height: 4,
                              width: 90,
                              color: Colors.yellow,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),

                  if(!isSignup) //로그인 창
                  Container(
                    margin: EdgeInsets.only(top:20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          //로그인 텍스트폼필드
                          TextFormField(
                            key: ValueKey(1),
                            decoration: const InputDecoration(//텍스트 필드 커스텀
                              prefixIcon: Icon(Icons.how_to_reg,color: Colors.grey,),
                              enabledBorder: OutlineInputBorder( //누르지 않았을시
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.all(Radius.circular(35.0))
                              ),
                              focusedBorder: OutlineInputBorder(//눌렀을시
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.all(Radius.circular(35.0))
                              ),
                              hintText: 'User ID',
                              hintStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.grey
                              ),
                              contentPadding: EdgeInsets.all(10), //텍스트 필드 padding 지정
                            ),
                            style: TextStyle(fontSize: 30),
                          ),
                          SizedBox(height: 30),

                          //패스워드 텍스트 폼 필드
                          TextFormField(
                            obscureText: true, //비밀번호가 안보이게함
                            key: ValueKey(2),
                            decoration: const InputDecoration( //텍스트 필드 커스텀
                              prefixIcon: Icon(Icons.lock,color: Colors.grey,),
                              enabledBorder: OutlineInputBorder( //누르지 않았을시
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.all(Radius.circular(35.0))
                              ),
                              focusedBorder: OutlineInputBorder(//눌렀을시
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.all(Radius.circular(35.0))
                              ),
                              hintText: 'User password',
                              hintStyle: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey
                              ),
                              contentPadding: EdgeInsets.all(10), //텍스트 필드 padding 지정
                            ),
                            style: TextStyle(fontSize: 30),
                          ),
                          SizedBox(height: 30),

                          SizedBox(height: MediaQuery.of(context).size.height - 760),
                          ElevatedButton(
                              onPressed: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => Frame()));
                              },
                              child: const Text('Login',
                                style: TextStyle(
                                    fontSize: 20
                                ),
                              ),
                          )
                        ],
                      ),
                    ),
                  ),

                  if(isSignup) //회원가입 창
                    Container(
                      margin: EdgeInsets.only(top:20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            //ID 텍스트폼필드
                            TextFormField(
                              key: ValueKey(3),
                              validator: (value){ //조건 검사
                                if(value!.isEmpty || !value.contains(RegExp('[0-9]'))){
                                  return "아이디에 숫자를 포합시켜주세요.";
                                } return null;
                              },
                              onSaved: (value){
                                userID = value!;
                              },
                              onChanged: (value){
                                userID = value;
                              },
                              decoration: const InputDecoration(//텍스트 필드 커스텀
                                prefixIcon: Icon(Icons.how_to_reg,color: Colors.grey,),
                                enabledBorder: OutlineInputBorder( //누르지 않았을시
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.all(Radius.circular(35.0))
                                ),
                                focusedBorder: OutlineInputBorder(//눌렀을시
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.all(Radius.circular(35.0))
                                ),
                                hintText: 'User ID',
                                hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey
                                ),
                                contentPadding: EdgeInsets.all(10), //텍스트 필드 padding 지정
                              ),
                              style: TextStyle(fontSize: 30),
                            ),
                            SizedBox(height: 30),

                            //패스워드 텍스트 폼 필드
                            TextFormField(
                              obscureText: true, //비밀번호가 안보이게함
                              key: ValueKey(4),
                              validator: (value){
                                if(value!.isEmpty || value.length < 6){
                                  return "비밀번호는 6자 이상 입력해야 합니다.";
                                }return null;
                              },
                              onSaved: (value){
                                userPassword = value!;
                              },
                              onChanged: (value){
                                userPassword = value;
                              },
                              decoration: const InputDecoration( //텍스트 필드 커스텀
                                prefixIcon: Icon(Icons.lock,color: Colors.grey,),
                                enabledBorder: OutlineInputBorder( //누르지 않았을시
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.all(Radius.circular(35.0))
                                ),
                                focusedBorder: OutlineInputBorder(//눌렀을시
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.all(Radius.circular(35.0))
                                ),
                                hintText: 'User password',
                                hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey
                                ),
                                contentPadding: EdgeInsets.all(10), //텍스트 필드 padding 지정
                              ),
                              style: TextStyle(fontSize: 30),
                            ),
                            SizedBox(height: 30),

                            //닉네임 텍스트 폼 필드
                            TextFormField(
                              key: ValueKey(5),
                              validator: (value){
                                if(value!.isEmpty || value!.length < 3){
                                  return '3글자 이상의 이름을 입력해주세요.';
                                } return null;
                              },
                              onSaved: (value){
                                userName = value!;
                              },
                              onChanged: (value){
                                userName = value;
                              },
                              decoration: const InputDecoration( //텍스트 필드 커스텀
                                prefixIcon: Icon(Icons.account_circle,color: Colors.grey,),
                                enabledBorder: OutlineInputBorder( //누르지 않았을시
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.all(Radius.circular(35.0))
                                ),
                                focusedBorder: OutlineInputBorder(//눌렀을시
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.all(Radius.circular(35.0))
                                ),
                                hintText: 'User name',
                                hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey
                                ),
                                contentPadding: EdgeInsets.all(10), //텍스트 필드 padding 지정
                              ),
                              style: TextStyle(fontSize: 30),
                            ),

                            SizedBox(height: 60),
                            ElevatedButton(
                              onPressed: () async{
                                _tryValidation();
                                print('sibal!!!!!!!!!!!!!!!!!!!!!!!!!!');

                                try{
                                  final newUser = await _authentication.createUserWithEmailAndPassword(
                                      email: userID, password: userPassword);

                                if(newUser.user != null){
                                    setState(() {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('회원가입 완료!!')));
                                      isSignup = false;
                                    });
                                  }
                                }catch(e){ //오류 발생시 스낵바로 알려줌
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('에러발생 아이디와 비밀번호를 다시 체크해주십쇼')));
                                }

                              },
                              child: const Text('Signup',
                              style: TextStyle(
                                fontSize: 20
                              ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
