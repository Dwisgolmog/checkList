import 'package:flutter/material.dart';
import 'package:checklist/frame.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginSignup extends StatefulWidget {
  const LoginSignup({Key? key}) : super(key: key);

  @override
  State<LoginSignup> createState() => _LoginSignupState();
}

class _LoginSignupState extends State<LoginSignup> {
  //이메일과 패스워들을 이용한 사용자 등록 또는 로그인기능을 가진 매서드를 사용가능하게 함
  final _authentication = FirebaseAuth.instance;

  bool isSignup = true; //메뉴 선택시(Login or Singup)판단하기 위한 변수
  final _formKey = GlobalKey<FormState>(); //폼에 부여할 글로벌 키 생성
  //input값에 들어갈 변수 초기화
  String userID = '';
  String userPassword = '';
  String userName = '';

  //텍스트폼에 있는 validate 체크하고 save의 내용을 보여지게 하는 함수
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
                            validator: (value){ //조건 검사
                              if(value!.isEmpty){
                                return "아이디를 입력해주세요.";
                              } return null;
                            },
                            onSaved: (value){ //validation을 위한 메서드
                              userID = value!;
                            },
                            onChanged: (value){ //텍스트폼에 입력된 값을 직접가져오는 메서드
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
                            key: ValueKey(2),
                            validator: (value){ //조건 검사
                              if(value!.isEmpty){
                                return "비밀번호를 입력해주세요.";
                              } return null;
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

                          SizedBox(height: MediaQuery.of(context).size.height - 730),

                          //login 버튼
                          ElevatedButton(
                              onPressed: () async{
                                _tryValidation();

                                try{
                                  //로그인 기능
                                  final newUser = await _authentication.signInWithEmailAndPassword(
                                      email: userID,
                                      password: userPassword);

                                  //로그인 성공시 다음페이지로 넘어감
                                  if(newUser.user != null){
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => FramePage()));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('login 성공')));
                                  }
                                }catch(e){ //오류 발생시 스낵바로 알려줌
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('에러발생 아이디와 비밀번호를 다시 체크해주십쇼')));
                                }
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
                                if(value!.isEmpty || !value.contains(RegExp('[0-9]')) ||
                                  !value.contains('@')
                                ){
                                  return "아이디를 숫자포함 또는 이메일 형식으로 입력해주세요.";
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

                            //Signup 버튼
                            ElevatedButton(
                              onPressed: () async{
                                _tryValidation();
                                //아이디중복과 같은 에러처리를 위한 예외처리
                                try{
                                  //신규 계정 생성 (새로운 계정등록후에 다음과정이 진행 되야 함으로 await 사용)
                                  final newUser = await _authentication.createUserWithEmailAndPassword(
                                      email: userID, password: userPassword);

                                  //user라는 데이터베이스를 생성하여 map 형태로 데이터를 저장
                                  await FirebaseFirestore.instance.collection('user').doc(newUser.user!.uid)
                                  .set({
                                    'userName' : userName,
                                    'userID' : userID,
                                    'picked_image' : '',
                                  });

                                if(newUser.user != null){
                                    setState(() {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('회원가입 완료!!')));
                                      isSignup = false;
                                    });
                                  }
                                }catch(e){ //오류 발생시 스낵바로 알려줌
                                  print('오류');
                                  print(e);
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
