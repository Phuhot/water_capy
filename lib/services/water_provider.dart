import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import '../utils/reminder_scheduler.dart';

class WaterProvider with ChangeNotifier {
  int _currentWater = 0;
  int _dailyGoal = 2000;
  String _userName = 'Bạn';
  String _gender = 'Khác';
  int _weight = 50;
  String _wakeTime = '07:00';
  String _sleepTime = '22:30';
  bool _reminderEnabled = true;
  int _reminderInterval = 60; // phút

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
  bool get reminderEnabled => _reminderEnabled;
  int get reminderInterval => _reminderInterval;
  List<Map<String, dynamic>> get dailyLogs => _dailyLogs;

  double get progress =>
      _dailyGoal > 0 ? (_currentWater / _dailyGoal).clamp(0.0, 1.0) : 0.0;

  /// 3 mốc nhắc sắp tới (đúng với lịch thông báo đã đặt)
  List<DateTime> get upcomingReminders => ReminderScheduler.upcoming(
    wakeTime: _wakeTime,
    sleepTime: _sleepTime,
    intervalMinutes: _reminderInterval,
    now: DateTime.now(),
  );

  static String _todayStr() => DateTime.now().toIso8601String().split('T')[0];

  // Nếu app vẫn mở qua nửa đêm thì lượng nước hôm qua phải về 0
  Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final today = _todayStr();
    if (prefs.getString('lastDate') != today) {
      _currentWater = 0;
      await prefs.setInt('currentWater', 0);
      await prefs.setString('lastDate', today);
    }
  }

  /// Gọi khi app quay lại foreground
  Future<void> refreshDay() async {
    final prefs = await SharedPreferences.getInstance();
    final before = _currentWater;
    await _resetIfNewDay(prefs);
    if (before != _currentWater) notifyListeners();
  }

  /// Đặt lại toàn bộ lịch nhắc theo cài đặt hiện tại
  Future<void> syncReminders() => _syncReminders();

  Future<void> _syncReminders() {
    return NotificationService.scheduleDailyReminders(
      enabled: _reminderEnabled,
      wakeTime: _wakeTime,
      sleepTime: _sleepTime,
      intervalMinutes: _reminderInterval,
      userName: _userName,
    );
  }

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
    _reminderEnabled = prefs.getBool('reminderEnabled') ?? true;
    _reminderInterval = prefs.getInt('reminderInterval') ?? 60;

    _currentWater = prefs.getInt('currentWater') ?? 0;
    await _resetIfNewDay(prefs);

    String? logsString = prefs.getString('dailyLogs');
    if (logsString != null) {
      List<dynamic> decoded = jsonDecode(logsString);
      _dailyLogs = decoded
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } else {
      // Sau khi Reset app, không giữ lại lịch sử cũ trong bộ nhớ
      _dailyLogs = [];
    }
    notifyListeners();

    // Chỉ đặt lịch nhắc khi đã qua bước làm quen
    if (!(prefs.getBool('isFirstTime') ?? true)) {
      await _syncReminders();
    }
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
    await _syncReminders(); // Tên mới trong nội dung thông báo
  }

  // Cập nhật Mục tiêu
  Future<void> updateGoal(int goal) async {
    goal = goal.clamp(500, 10000);
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
    await _syncReminders();
  }

  // Bật / tắt nhắc uống nước
  Future<void> setReminderEnabled(bool enabled) async {
    _reminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminderEnabled', enabled);
    notifyListeners();
    await _syncReminders();
  }

  // Đổi khoảng cách giữa 2 lần nhắc
  Future<void> setReminderInterval(int minutes) async {
    _reminderInterval = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderInterval', minutes);
    notifyListeners();
    await _syncReminders();
  }

  Future<void> addWater(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    _currentWater += amount;
    _dailyLogs.insert(0, {
      'amount': amount,
      'time': DateTime.now().toIso8601String(),
    });
    await prefs.setInt('currentWater', _currentWater);
    await prefs.setString('dailyLogs', jsonEncode(_dailyLogs));
    notifyListeners();
  }

  // Xóa một lần uống bị bấm nhầm (nếu là của hôm nay thì trừ lại lượng nước)
  Future<void> removeLog(Map<String, dynamic> log) async {
    if (!_dailyLogs.remove(log)) return;
    final isToday = (log['time'] as String).startsWith(_todayStr());
    if (isToday) {
      _currentWater = max(0, _currentWater - (log['amount'] as int));
    }
    // Cập nhật giao diện ngay (Dismissible yêu cầu item biến mất liền)
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (isToday) await prefs.setInt('currentWater', _currentWater);
    await prefs.setString('dailyLogs', jsonEncode(_dailyLogs));
  }
}
