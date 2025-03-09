import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart'; // 날짜 포맷 라이브러리 추가
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';


class BloodSugarGraphScreen extends StatefulWidget {
  @override
  _BloodSugarGraphScreenState createState() => _BloodSugarGraphScreenState();
}

class _BloodSugarGraphScreenState extends State<BloodSugarGraphScreen> {

  //목표 혈당 가져오기
  double minBloodSugarGoal = 70;
  double maxBloodSugarGoal = 140;

  Future<void> _loadBloodSugarGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      minBloodSugarGoal = prefs.getDouble('minBloodSugar') ?? 70;
      maxBloodSugarGoal = prefs.getDouble('maxBloodSugar') ?? 140;
    });
  }

  //평균혈당 계산
  double _calculateAverageBloodSugar(int days) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));

    final recentRecords = bloodSugarList
        .where((record) => DateTime.parse(record['date']).isAfter(cutoffDate))
        .map((record) => (record['value'] as num).toDouble())
        .toList();

    if (recentRecords.isEmpty) return 0;

    double sum = recentRecords.reduce((a, b) => a + b);
    return sum / recentRecords.length;
  }


  List<Map<String, dynamic>> bloodSugarList = [];


  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // 타임존 데이터 초기화
    _loadBloodSugarRecords();
    _loadBloodSugarGoals(); // 목표 혈당 범위 불러오기 추가
  }


  void _loadBloodSugarRecords() async {
    final records = await DatabaseHelper.instance.getBloodSugarRecords();
    setState(() {
      bloodSugarList = records;
    });
  }

  List<FlSpot> _generateGraphData() {
    List<FlSpot> spots = [];
    for (int i = 0; i < bloodSugarList.length; i++) {
      double x = i.toDouble(); // X축을 인덱스로 설정 (나중에 날짜로 변환)
      double y = bloodSugarList[i]['value'].toDouble(); // Y축은 혈당 값
      spots.add(FlSpot(x, y));
    }
    return spots;
  }

  List<String> _generateXLabels() {
    List<String> labels = [];
    for (var record in bloodSugarList) {
      String formattedDate = _formatDateToNZ(record['date']);
      labels.add(formattedDate);
    }
    return labels;
  }

  String _formatDateToNZ(String dateString) {
    final dateTime = DateTime.parse(dateString).toUtc();
    final nzTimeZone = tz.getLocation('Pacific/Auckland'); // 뉴질랜드 오클랜드 시간대
    final nzDateTime = tz.TZDateTime.from(dateTime, nzTimeZone);
    return DateFormat('MM/dd').format(nzDateTime); // 날짜 형식 MM/DD로 변경
  }

  List<double> _getUniqueBloodSugarValues() {
    return bloodSugarList
        .map((record) => (record['value'] as num).toDouble()) // ✅ `as num`으로 변환 후 `.toDouble()`
        .toSet()
        .toList()
      ..sort();
  }

  double _getMinBloodSugar() {
    if (bloodSugarList.isEmpty) return 0; // 데이터가 없으면 0 반환
    return bloodSugarList.map((record) => (record['value'] as num).toDouble()).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxBloodSugar() {
    if (bloodSugarList.isEmpty) return 100; // 데이터가 없으면 100 반환 (기본값)
    return bloodSugarList.map((record) => (record['value'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('혈당 그래프'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings), // 설정 버튼 추가
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BloodSugarSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: bloodSugarList.isEmpty
            ? Center(child: Text("저장된 혈당 데이터가 없습니다."))
            : Column(
          children: [
            Text("최근 7일 평균 혈당: ${_calculateAverageBloodSugar(7).toStringAsFixed(1)} mg/dL",
                style: TextStyle(fontSize: 16)),
            Text("최근 30일 평균 혈당: ${_calculateAverageBloodSugar(30).toStringAsFixed(1)} mg/dL",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            Expanded(
              child: LineChart(
                LineChartData(

                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: minBloodSugarGoal,
                        color: Colors.green.withOpacity(0.3), // 목표 범위 하한선
                        strokeWidth: 2,
                      ),
                      HorizontalLine(
                        y: maxBloodSugarGoal,
                        color: Colors.green.withOpacity(0.3), // 목표 범위 상한선
                        strokeWidth: 2,
                      ),
                    ],
                  ),

                  minY: _getMinBloodSugar() - 10, // ✅ 최솟값보다 10 낮게 설정
                  maxY: _getMaxBloodSugar() + 10, // ✅ 최댓값보다 10 높게 설정

                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // ✅ 위쪽 X축 숫자 제거
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // ✅ 왼쪽 Y축 숫자 제거
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, // ✅ 오른쪽 Y축 숫자 표시
                        getTitlesWidget: (value, meta) {
                          // ✅ Y축에 실제 기록된 혈당 값만 표시
                          List<double> values = _getUniqueBloodSugarValues();
                          if (values.contains(value)) {
                            return Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(
                                value.toInt().toString(), // ✅ 가로 방향(한 줄)으로 표시
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return Text(""); // 표시할 값이 없으면 빈 문자열 반환
                        },
                        interval: 1, // ✅ 간격 조절
                        reservedSize: 40, // ✅ 너비 조절
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < bloodSugarList.length) {
                            return Text(_generateXLabels()[index], style: TextStyle(fontSize: 10));
                          }
                          return Text('');
                        },
                        interval: 1, // X축 간격 설정
                        reservedSize: 22,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateGraphData(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
