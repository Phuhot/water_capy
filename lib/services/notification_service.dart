import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static Future<void> initialize() async {
    if (kIsWeb) return;

    // Khởi tạo kênh thông báo
    await AwesomeNotifications().initialize(
      null, // Dùng icon mặc định của app
      [
        NotificationChannel(
          channelGroupKey: 'capy_group',
          channelKey: 'capy_water_channel',
          channelName: 'Capy Nhắc Nước',
          channelDescription: 'Kênh gửi nhắc nhở uống nước từ bé Capy',
          defaultColor: const Color(0xFF2196F3),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
        ),
      ],
    );

    // Tự động xin quyền thông báo nếu user chưa cấp
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
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
          100000,
        ), // ID ngẫu nhiên để không đè thông báo cũ
        channelKey: 'capy_water_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
