import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../utils/reminder_scheduler.dart';

class NotificationService {
  static const String channelKey = 'capy_water_channel';

  // ID cố định cho lịch nhắc: 1000, 1001, ... (thông báo tức thì dùng ID < 1000)
  static const int _reminderIdBase = 1000;

  // Xếp hàng các lần lên lịch để 2 lần gọi liền nhau không giẫm chân nhau
  static Future<void> _queue = Future.value();

  static final List<String> _reminderMessages = [
    'Capy khát rồi nè, làm một ngụm nước thôi! 💧',
    'Đến giờ nạp nước rồi đó, đừng để Capy chờ nha 🐹',
    'Một cốc nước mát cho ngày dài năng lượng!',
    'Uống nước đều đặn giúp da đẹp, đầu óc tỉnh táo ✨',
    'Capy nhắc nhẹ: uống nước đi nào!',
    'Nước lọc là chân ái! Uống miếng nha 💙',
  ];

  static Future<void> initialize() async {
    if (kIsWeb) return;

    // Khởi tạo kênh thông báo
    await AwesomeNotifications().initialize(
      null, // Dùng icon mặc định của app
      [
        NotificationChannel(
          channelGroupKey: 'capy_group',
          channelKey: channelKey,
          channelName: 'Capy Nhắc Nước',
          channelDescription: 'Kênh gửi nhắc nhở uống nước từ bé Capy',
          defaultColor: const Color(0xFF2196F3),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
        ),
      ],
    );
    // Không xin quyền ở đây: lúc này app chưa có giao diện (chưa runApp),
    // việc xin quyền được làm ở MainTabScreen.
  }

  static Future<bool> isAllowed() async {
    if (kIsWeb) return false;
    return AwesomeNotifications().isNotificationAllowed();
  }

  /// Xin quyền gửi thông báo nếu chưa có. Trả về true nếu đã được cấp.
  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    if (await AwesomeNotifications().isNotificationAllowed()) return true;
    return AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    // Bắn thông báo
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(
          _reminderIdBase,
        ), // ID ngẫu nhiên để không đè thông báo cũ
        channelKey: channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  /// Hủy toàn bộ lịch nhắc (dùng khi Reset app)
  static Future<void> cancelReminders() {
    _queue = _queue.then((_) async {
      if (kIsWeb) return;
      try {
        await AwesomeNotifications().cancelSchedulesByChannelKey(channelKey);
      } catch (e) {
        debugPrint('Lỗi hủy lịch nhắc: $e');
      }
    });
    return _queue;
  }

  /// Lên lịch nhắc uống nước lặp lại mỗi ngày từ giờ thức đến giờ ngủ.
  /// Gọi lại hàm này mỗi khi đổi giờ / khoảng nhắc: lịch cũ sẽ bị xóa trước.
  static Future<void> scheduleDailyReminders({
    required bool enabled,
    required String wakeTime,
    required String sleepTime,
    required int intervalMinutes,
    required String userName,
  }) {
    _queue = _queue.then((_) async {
      if (kIsWeb) return;
      try {
        await AwesomeNotifications().cancelSchedulesByChannelKey(channelKey);
        if (!enabled) return;

        final minutes = ReminderScheduler.buildReminderMinutes(
          wakeTime: wakeTime,
          sleepTime: sleepTime,
          intervalMinutes: intervalMinutes,
        );
        final timeZone = await AwesomeNotifications()
            .getLocalTimeZoneIdentifier();

        for (int i = 0; i < minutes.length; i++) {
          final hour = minutes[i] ~/ 60;
          final minute = minutes[i] % 60;
          final isFirst = i == 0;

          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: _reminderIdBase + i,
              channelKey: channelKey,
              title: isFirst
                  ? 'Chào buổi sáng $userName! ☀️'
                  : 'Ê $userName ơi! 🐹',
              body: isFirst
                  ? 'Mở đầu ngày mới bằng một cốc nước ấm nha!'
                  : _reminderMessages[i % _reminderMessages.length],
              category: NotificationCategory.Reminder,
              notificationLayout: NotificationLayout.Default,
              wakeUpScreen: true,
            ),
            schedule: NotificationCalendar(
              hour: hour,
              minute: minute,
              second: 0,
              millisecond: 0,
              repeats: true,
              allowWhileIdle: true,
              // Mặc định là true -> Android 12+ cần quyền "báo thức chính xác"
              // (Android 14 tắt sẵn) nên lịch nhắc không chạy. Lệch vài phút không sao.
              preciseAlarm: false,
              timeZone: timeZone,
            ),
          );
        }
      } catch (e) {
        debugPrint('Lỗi lên lịch nhắc uống nước: $e');
      }
    });
    return _queue;
  }
}
