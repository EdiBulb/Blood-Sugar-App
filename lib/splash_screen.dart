import 'package:flutter/material.dart';
import 'dart:async'; // ✅ Timer를 사용하기 위해 추가
import 'main.dart';  // ✅ 메인 화면으로 이동

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      // 📌 스플래시 후 메인 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => BloodSugarApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow, // 배경색
      body: Center(
        child: Image.asset('assets/nurse.png', width: 200), // 큰어머니 이미지
      ),
    );
  }
}