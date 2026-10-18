import 'package:flutter_test/flutter_test.dart';
import 'package:water_capy/utils/reminder_scheduler.dart';

void main() {
  group('ReminderScheduler.buildReminderMinutes', () {
    test('nhắc mỗi giờ từ 07:00 đến trước 22:30', () {
      final minutes = ReminderScheduler.buildReminderMinutes(
        wakeTime: '07:00',
        sleepTime: '22:30',
        intervalMinutes: 60,
      );
      expect(minutes.first, 7 * 60);
      expect(minutes.last, 22 * 60);
      expect(minutes.length, 16);
    });

    test('hỗ trợ giờ không đệm số 0 (7:05)', () {
      final minutes = ReminderScheduler.buildReminderMinutes(
        wakeTime: '7:05',
        sleepTime: '9:00',
        intervalMinutes: 30,
      );
      expect(minutes, [425, 455, 485, 515]);
    });

    test('lịch ngủ qua đêm', () {
      final minutes = ReminderScheduler.buildReminderMinutes(
        wakeTime: '22:00',
        sleepTime: '01:00',
        intervalMinutes: 60,
      );
      expect(minutes, [22 * 60, 23 * 60, 0]);
    });

    test('không vượt giới hạn thông báo của iOS', () {
      final minutes = ReminderScheduler.buildReminderMinutes(
        wakeTime: '00:00',
        sleepTime: '00:00',
        intervalMinutes: 15,
      );
      expect(minutes.length, ReminderScheduler.maxReminders);
    });
  });

  group('ReminderScheduler.upcoming', () {
    test('lấy các mốc tiếp theo, tràn sang ngày mai', () {
      final upcoming = ReminderScheduler.upcoming(
        wakeTime: '07:00',
        sleepTime: '22:30',
        intervalMinutes: 60,
        now: DateTime(2026, 10, 18, 21, 10),
      );
      expect(upcoming, [
        DateTime(2026, 10, 18, 22, 0),
        DateTime(2026, 10, 19, 7, 0),
        DateTime(2026, 10, 19, 8, 0),
      ]);
    });
  });
}
