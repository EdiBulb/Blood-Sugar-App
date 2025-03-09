import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BloodSugarSettingsScreen extends StatefulWidget {
  @override
  _BloodSugarSettingsScreenState createState() => _BloodSugarSettingsScreenState();
}

class _BloodSugarSettingsScreenState extends State<BloodSugarSettingsScreen> {
  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      minController.text = (prefs.getDouble('minBloodSugar') ?? 70).toString();
      maxController.text = (prefs.getDouble('maxBloodSugar') ?? 140).toString();
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('minBloodSugar', double.parse(minController.text));
    await prefs.setDouble('maxBloodSugar', double.parse(maxController.text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('목표 혈당 범위가 저장되었습니다!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('목표 혈당 설정')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: minController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '목표 혈당 최솟값 (mg/dL)'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: maxController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '목표 혈당 최댓값 (mg/dL)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
