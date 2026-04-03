import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterProvider with ChangeNotifier {
  int _currentWater = 0;
  int _dailyGoal = 2000;
  String _userName = 'Bạn';
  String _gender = 'Khác';
  int _weight = 50;
  String _wakeTime = '07:00';
  String _sleepTime = '22:30';

  int _selectedCupAmount = 250;
  int get selectedCupAmount => _selectedCupAmount;

  void selectCup(int amount) {
    _selectedCupAmount = amount;
    notifyListeners();
  }

  List<Map<String, dynamic>> _dailyLogs = [];

  int get currentWater => _currentWater;
  int get dailyGoal => _dailyGoal;
  String get userName => _userName;
  String get gender => _gender;
  int get weight => _weight;
  String get wakeTime => _wakeTime;
  String get sleepTime => _sleepTime;
  List<Map<String, dynamic>> get dailyLogs => _dailyLogs;

  double get progress =>
      _dailyGoal > 0 ? (_currentWater / _dailyGoal).clamp(0.0, 1.0) : 0.0;

  // === LOGIC TẠO THANH STREAK 7 NGÀY ===
  List<Map<String, dynamic>> get last7DaysStreak {
    List<Map<String, dynamic>> streak = [];
    DateTime today = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime targetDate = today.subtract(Duration(days: i));
      String targetDateStr = targetDate.toIso8601String().split('T')[0];

      // Kiểm tra xem ngày đó có dữ liệu uống nước không (>0)
      bool hasWater = _dailyLogs.any(
        (log) => (log['time'] as String).startsWith(targetDateStr),
      );

      String dayName = i == 0
          ? 'Nay'
          : ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][targetDate.weekday % 7];
      streak.add({'day': dayName, 'achieved': hasWater});
    }
    return streak;
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyGoal = prefs.getInt('dailyGoal') ?? 2000;
    _userName = prefs.getString('userName') ?? 'Bạn';
    _gender = prefs.getString('gender') ?? 'Khác';
    _weight = prefs.getInt('weight') ?? 50;
    _wakeTime = prefs.getString('wakeTime') ?? '07:00';
    _sleepTime = prefs.getString('sleepTime') ?? '22:30';

    String today = DateTime.now().toIso8601String().split('T')[0];
    String savedDate = prefs.getString('lastDate') ?? '';

    if (today != savedDate) {
      _currentWater = 0;
      await prefs.setInt('currentWater', 0);
      await prefs.setString('lastDate', today);
    } else {
      _currentWater = prefs.getInt('currentWater') ?? 0;
    }

    String? logsString = prefs.getString('dailyLogs');
    if (logsString != null) {
      List<dynamic> decoded = jsonDecode(logsString);
      _dailyLogs = decoded
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    notifyListeners();
  }

  // Cập nhật Hồ sơ cá nhân
  Future<void> updateProfile(String name, String gender, int weight) async {
    _userName = name;
    _gender = gender;
    _weight = weight;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('gender', gender);
    await prefs.setInt('weight', weight);
    notifyListeners();
  }

  // Cập nhật Mục tiêu
  Future<void> updateGoal(int goal) async {
    _dailyGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoal', goal);
    notifyListeners();
  }

  // Cập nhật Giờ sinh hoạt
  Future<void> updateSchedule(String wake, String sleep) async {
    _wakeTime = wake;
    _sleepTime = sleep;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wakeTime', wake);
    await prefs.setString('sleepTime', sleep);
    notifyListeners();
  }

  Future<void> addWater(int amount) async {
    _currentWater += amount;
    _dailyLogs.insert(0, {
      'amount': amount,
      'time': DateTime.now().toIso8601String(),
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentWater', _currentWater);
    await prefs.setString('dailyLogs', jsonEncode(_dailyLogs));
    notifyListeners();
  }
}
