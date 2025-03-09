import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'graph_screen.dart';
import 'tips.dart';
import 'package:intl/intl.dart'; // 날짜 포맷 라이브러리 추가
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'blood_sugar_input.dart'; // ✅ 혈당 입력 화면 가져오기

void main() {
  tz.initializeTimeZones(); // 타임존 데이터 초기화
  runApp(BloodSugarApp());
}

class BloodSugarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '혈당 관리 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BloodSugarInputScreen(),
    );
  }
}

class BloodSugarInputScreen extends StatefulWidget {
  @override
  _BloodSugarInputScreenState createState() => _BloodSugarInputScreenState();
}

class _BloodSugarInputScreenState extends State<BloodSugarInputScreen> {
  final TextEditingController _controller = TextEditingController();
  String? selectedMeal;
  String? selectedExercise;
  String? memo;
  List<Map<String, dynamic>> bloodSugarList = [];
  String _tip = BloodSugarTips.getRandomTip();

  final List<String> meals = ['아침 전', '아침 후', '점심 전', '점심 후', '저녁 전', '저녁 후', '간식'];
  final List<String> exercises = ['운동 전', '운동 후', '가벼운 운동', '강한 운동'];

  @override
  void initState() {
    super.initState();
    _loadBloodSugarRecords();
  }

  void _loadBloodSugarRecords() async {
    final records = await DatabaseHelper.instance.getBloodSugarRecords();
    setState(() {
      bloodSugarList = records;
    });
  }

  void _saveBloodSugar() async {
    final double? bloodSugar = double.tryParse(_controller.text);
    if (bloodSugar == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('혈당 값을 입력하세요!')));
      return;
    }

    final newRecord = {
      'value': bloodSugar,
      'date': DateTime.now().toIso8601String(),
      'meal': selectedMeal ?? '',
      'exercise': selectedExercise ?? '',
      'memo': memo ?? '',
    };

    await DatabaseHelper.instance.insertBloodSugar(newRecord);
    _controller.clear();
    selectedMeal = null;
    selectedExercise = null;
    memo = '';

    _loadBloodSugarRecords();
  }

  void _deleteBloodSugar(int id) async {
    await DatabaseHelper.instance.deleteBloodSugar(id);
    _loadBloodSugarRecords();
  }

  void _refreshTip() {
    setState(() {
      _tip = BloodSugarTips.getRandomTip();
    });
  }

  String _formatDateToNZ(String dateString) {
    final dateTime = DateTime.parse(dateString).toUtc();
    final nzTimeZone = tz.getLocation('Pacific/Auckland'); // 뉴질랜드 오클랜드 타임존
    final nzDateTime = tz.TZDateTime.from(dateTime, nzTimeZone);
    return DateFormat('yyyy-MM-dd HH:mm').format(nzDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('혈당 입력')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.blue[100],
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      "💡 혈당 관리 팁",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _tip,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshTip,
                      child: Text("새로운 팁 보기"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '혈당 수치 입력',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: '식사 여부'),
              value: selectedMeal,
              items: meals.map((meal) => DropdownMenuItem(value: meal, child: Text(meal))).toList(),
              onChanged: (value) => setState(() => selectedMeal = value),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: '운동 여부'),
              value: selectedExercise,
              items: exercises.map((exercise) => DropdownMenuItem(value: exercise, child: Text(exercise))).toList(),
              onChanged: (value) => setState(() => selectedExercise = value),
            ),
            TextField(
              decoration: InputDecoration(labelText: '메모 (선택)'),
              onChanged: (value) => setState(() => memo = value),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveBloodSugar,
              child: Text('저장'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BloodSugarGraphScreen()),
                );
              },
              child: Text('혈당 그래프 보기'),
            ),
            SizedBox(height: 20),
            Text('저장된 혈당 기록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: bloodSugarList.length,
                itemBuilder: (context, index) {
                  final record = bloodSugarList[index];
                  return Card(
                    child: ListTile(
                      title: Text('혈당: ${record['value']} mg/dL'),
                      subtitle: Text(
                        '시간: ${_formatDateToNZ(record['date'])}\n'
                            '식사: ${record['meal']}\n'
                            '운동: ${record['exercise']}\n'
                            '메모: ${record['memo']}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBloodSugar(record['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
