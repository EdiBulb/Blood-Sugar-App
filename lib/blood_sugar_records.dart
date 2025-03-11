import 'package:flutter/material.dart';
import 'database_helper.dart'; // ✅ 데이터베이스 불러오기

class BloodSugarRecordsScreen extends StatefulWidget {
  @override
  _BloodSugarRecordsScreenState createState() => _BloodSugarRecordsScreenState();
}

class _BloodSugarRecordsScreenState extends State<BloodSugarRecordsScreen> {
  List<Map<String, dynamic>> bloodSugarList = [];

  @override
  void initState() {
    super.initState();
    _loadBloodSugarRecords();
  }

  Future<void> _loadBloodSugarRecords() async {
    final records = await DatabaseHelper.instance.getBloodSugarRecords();
    setState(() {
      bloodSugarList = records;
    });
  }

  Future<void> _deleteBloodSugar(int index, int id) async {
    await DatabaseHelper.instance.deleteBloodSugar(id);
    setState(() {
      bloodSugarList.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('혈당 기록이 삭제되었습니다!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('혈당 기록')),
      body: bloodSugarList.isEmpty
          ? Center(child: Text('저장된 혈당 기록이 없습니다.'))
          : ListView.builder(
        itemCount: bloodSugarList.length,
        itemBuilder: (context, index) {
          final record = bloodSugarList[index];
          return Card(
            color: Colors.amber[200], // ✅ 노란색 테마 적용
            child: ListTile(
              title: Text('혈당: ${record['value']} mg/dL'),
              subtitle: Text('${record['date']} | ${record['meal']} | ${record['exercise']}'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteBloodSugar(index, record['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
