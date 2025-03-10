import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart'; // ✅ SQLite 데이터베이스 불러오기

class BloodSugarInputScreen extends StatefulWidget {
  @override
  _BloodSugarInputScreenState createState() => _BloodSugarInputScreenState();
}

class _BloodSugarInputScreenState extends State<BloodSugarInputScreen> {
  final TextEditingController _bloodSugarController = TextEditingController();
  String? selectedMeal;
  String? selectedExercise;
  String? memo;
  final List<String> meals = ['아침 전', '아침 후', '점심 전', '점심 후', '저녁 전', '저녁 후', '간식'];
  final List<String> exercises = ['운동 전', '운동 후', '가벼운 운동', '강한 운동'];

  List<Map<String, dynamic>> bloodSugarList = []; // ✅ 입력한 데이터를 리스트로 저장

  @override
  void initState() {
    super.initState();
    _loadBloodSugarRecords(); // ✅ 앱 실행 시 데이터 불러오기
  }

  Future<void> _loadBloodSugarRecords() async {
    final records = await DatabaseHelper.instance.getBloodSugarRecords();
    setState(() {
      bloodSugarList = records;
    });
  }

  Future<void> _saveBloodSugar() async {
    final double? bloodSugar = double.tryParse(_bloodSugarController.text);
    if (bloodSugar == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('혈당 값을 입력하세요!')));
      return;
    }

    final newRecord = {
      'value': bloodSugar,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'meal': selectedMeal ?? '',
      'exercise': selectedExercise ?? '',
      'memo': memo ?? '',
    };

    await DatabaseHelper.instance.insertBloodSugar(newRecord); // ✅ DB에 저장

    setState(() {
      bloodSugarList.insert(0, newRecord); // ✅ 리스트에 새 데이터 추가 (최신 데이터가 위로)
      _bloodSugarController.clear();
      selectedMeal = null;
      selectedExercise = null;
      memo = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('혈당 기록이 저장되었습니다!')));
  }

  Future<void> _deleteBloodSugar(int index, int id) async {
    await DatabaseHelper.instance.deleteBloodSugar(id);
    setState(() {
      bloodSugarList.removeAt(index); // ✅ 리스트에서 해당 데이터 삭제
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('혈당 기록이 삭제되었습니다!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('혈당 기록 입력')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _bloodSugarController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '혈당 수치 입력'),
            ),
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
            SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, // ✅ 노란색 버튼
                  foregroundColor: Colors.white, // 글자 색상
                ),
                onPressed: _saveBloodSugar,
                child: Text('저장')
            ),

            SizedBox(height: 20),

            Expanded(
              child: bloodSugarList.isEmpty
                  ? Center(child: Text('저장된 혈당 기록이 없습니다.'))
                  : ListView.builder(
                itemCount: bloodSugarList.length,
                itemBuilder: (context, index) {
                  final record = bloodSugarList[index];
                  return Card(
                    color: Colors.amber[200], // ✅ 혈당 팁 카드도 노란색으로 변경
                    child: ListTile(
                      title: Text('혈당: ${record['value']} mg/dL'),
                      subtitle: Text('${record['date']} | ${record['meal']} | ${record['exercise']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBloodSugar(index, record['id']), // ✅ 삭제 기능 추가
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
