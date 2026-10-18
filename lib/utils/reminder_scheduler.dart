/// Tính các mốc giờ nhắc uống nước trong ngày (thuần Dart, không phụ thuộc plugin
/// nên có thể viết unit test).
class ReminderScheduler {
  /// Giới hạn số lịch nhắc: iOS chỉ cho tối đa 64 thông báo chờ cùng lúc.
  static const int maxReminders = 60;

  /// Các khoảng nhắc người dùng có thể chọn (phút).
  static const List<int> intervalOptions = [30, 45, 60, 90, 120];

  /// Đổi chuỗi 'HH:mm' (hoặc 'H:mm') thành số phút tính từ 0h.
  static int parseMinutes(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return (hour.clamp(0, 23)) * 60 + minute.clamp(0, 59);
  }

  /// Trả về danh sách mốc giờ (phút trong ngày, 0..1439) từ lúc thức dậy,
  /// cách nhau [intervalMinutes], dừng trước giờ đi ngủ.
  /// Hỗ trợ cả lịch ngủ qua đêm (vd: thức 14:00, ngủ 02:00).
  static List<int> buildReminderMinutes({
    required String wakeTime,
    required String sleepTime,
    required int intervalMinutes,
  }) {
    if (intervalMinutes <= 0) return [];

    final wake = parseMinutes(wakeTime);
    var sleep = parseMinutes(sleepTime);
    if (sleep <= wake) sleep += 24 * 60; // Ngủ xuyên đêm

    final result = <int>[];
    for (
      var t = wake;
      t < sleep && result.length < maxReminders;
      t += intervalMinutes
    ) {
      result.add(t % (24 * 60));
    }
    return result;
  }

  /// Các mốc nhắc sắp tới tính từ [now] (tối đa [count] mốc), dùng cho màn hình chính.
  static List<DateTime> upcoming({
    required String wakeTime,
    required String sleepTime,
    required int intervalMinutes,
    required DateTime now,
    int count = 3,
  }) {
    final minutes = buildReminderMinutes(
      wakeTime: wakeTime,
      sleepTime: sleepTime,
      intervalMinutes: intervalMinutes,
    );
    if (minutes.isEmpty) return [];

    final today = DateTime(now.year, now.month, now.day);
    final result = <DateTime>[];
    // Xét hôm nay và ngày mai là đủ để tìm [count] mốc tiếp theo.
    for (
      var dayOffset = 0;
      dayOffset < 2 && result.length < count;
      dayOffset++
    ) {
      final sorted = [...minutes]..sort();
      for (final m in sorted) {
        final time = DateTime(
          today.year,
          today.month,
          today.day + dayOffset,
          m ~/ 60,
          m % 60,
        );
        if (time.isAfter(now)) result.add(time);
        if (result.length >= count) break;
      }
    }
    return result;
  }
}
