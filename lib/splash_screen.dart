import 'package:flutter/material.dart'; // Flutter의 UI 구성 요소를 사용하기 위해서 필요
import 'dart:async'; //  Timer를 사용하기 위해 추가
import 'main.dart';  //  메인 화면으로 이동

// 앱 시작 시 잠깐 보여주는 화면
//StatefulWidget을 사용하는 이유: 스플래시 화면에서 3초 뒤에 다음 화면으로 이동해야하기 때문에
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

//스플래시 로직
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { // 위젯이 처음 생성될 때 단 한 번 실행되는 함수
    super.initState();
    Timer(Duration(seconds: 3), () {
      // 3초 후 메인 화면으로 이동
      Navigator.of(context).pushReplacement( // pushReplacement: 현재 화면을 새로운 화면으로 교체하고, 뒤로 가기를 막음
        MaterialPageRoute(builder: (context) => BloodSugarInputScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) { //build()함수는 기본적인 화면 레이아웃
    return Scaffold(
      backgroundColor: Colors.amber[500], // 배경색
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle, // ✅ 원형으로 설정
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // ✅ 그림자 효과 추가
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100), // ✅ 이미지 둥글게
            child: Image.asset(
              'assets/nurse.png', // ✅ 이미지 파일 경로 (파일명 확인)
              width: 150, // 이미지 크기 조정
              height: 150,
              fit: BoxFit.cover, // 이미지를 꽉 차게 설정
            ),
          ),
        ),
      ),
    );
  }
}