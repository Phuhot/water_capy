import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/water_provider.dart';
import '../services/theme_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';
import '../utils/reminder_scheduler.dart';
import '../utils/ui_helpers.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showEditProfile(BuildContext context, WaterProvider provider) {
    final nameCtrl = TextEditingController(text: provider.userName);
    String selectedGender = provider.gender;
    double selectedWeight = provider.weight.toDouble();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Sửa Hồ Sơ',
            style: TextStyle(
              color: AppTheme.oceanBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tên gọi:'),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(isDense: true),
                ),
                const SizedBox(height: 16),
                const Text('Giới tính:'),
                DropdownButton<String>(
                  value: selectedGender,
                  isExpanded: true,
                  items: ['Nam', 'Nữ', 'Khác']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedGender = val!),
                ),
                const SizedBox(height: 16),
                Text('Cân nặng: ${selectedWeight.toInt()} kg'),
                Slider(
                  value: selectedWeight,
                  min: 30,
                  max: 150,
                  activeColor: AppTheme.oceanBlue,
                  onChanged: (val) => setState(() => selectedWeight = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.oceanBlue,
              ),
              onPressed: () {
                provider.updateProfile(
                  nameCtrl.text.trim(),
                  selectedGender,
                  selectedWeight.toInt(),
                );
                Navigator.pop(context);
              },
              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGoal(BuildContext context, WaterProvider provider) {
    final ctrl = TextEditingController(text: provider.dailyGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Mục tiêu (ml)'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.oceanBlue,
            ),
            onPressed: () {
              provider.updateGoal(int.tryParse(ctrl.text) ?? 2000);
              Navigator.pop(context);
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditSchedule(BuildContext context, WaterProvider provider) async {
    TimeOfDay? wake = await showTimePicker(
      context: context,
      helpText: 'Giờ thức dậy',
      initialTime: TimeOfDay(
        hour: int.parse(provider.wakeTime.split(':')[0]),
        minute: int.parse(provider.wakeTime.split(':')[1]),
      ),
    );
    if (wake == null || !context.mounted) return;

    TimeOfDay? sleep = await showTimePicker(
      context: context,
      helpText: 'Giờ đi ngủ',
      initialTime: TimeOfDay(
        hour: int.parse(provider.sleepTime.split(':')[0]),
        minute: int.parse(provider.sleepTime.split(':')[1]),
      ),
    );
    if (sleep == null) return;

    provider.updateSchedule(
      '${wake.hour.toString().padLeft(2, '0')}:${wake.minute.toString().padLeft(2, '0')}',
      '${sleep.hour.toString().padLeft(2, '0')}:${sleep.minute.toString().padLeft(2, '0')}',
    );
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return '$minutes phút';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h giờ' : '${h}h${m.toString().padLeft(2, '0')}';
  }

  // Bảng chọn khoảng nhắc (cùng kiểu với bảng chọn cốc ở Trang chủ)
  void _showIntervalSheet(BuildContext context, WaterProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Capy nhắc bạn mỗi...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: ReminderScheduler.intervalOptions.map((minutes) {
                  final isSelected = provider.reminderInterval == minutes;
                  return GestureDetector(
                    onTap: () {
                      provider.setReminderInterval(minutes);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 90,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.oceanBlue
                            : AppTheme.oceanBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.alarm,
                            size: 22,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.oceanBlue,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatInterval(minutes),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.oceanBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendTestNotification(
    BuildContext context,
    WaterProvider provider,
  ) async {
    final allowed = await NotificationService.requestPermission();
    if (!context.mounted) return;
    if (!allowed) {
      showCuteSnackbar(
        context,
        'Bạn chưa cho phép thông báo. Vào Cài đặt máy > Water Capy để bật nha!',
      );
      return;
    }
    await NotificationService.showInstantNotification(
      title: 'Ê ${provider.userName} ơi! 🐹',
      body: 'Capy test thông báo nè. Nhận được là ngon lành rồi đó!',
    );
    if (context.mounted) showCuteSnackbar(context, 'Đã gửi thông báo thử!');
  }

  // BẢNG ĐIỀU KHOẢN SIÊU LẦY LỘI NẰM Ở ĐÂY NÈ
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.gavel, color: AppTheme.oceanBlue),
            SizedBox(width: 8),
            Text(
              'Điều khoản Capy',
              style: TextStyle(
                color: AppTheme.oceanBlue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/images/capy_2.png', height: 80)),
            const SizedBox(height: 16),
            const Text(
              '1. Bạn phải cam kết uống đủ nước mỗi ngày để Capy vui.\n\n2. Cấm uống trà sữa rồi khai báo vào app là uống nước lọc.\n\n3. Yêu thương và không bỏ đói Capy.\n\n4. Mọi lỗi lầm đều thuộc về người dùng, nhà phát triển vô tội 🐹.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.oceanBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đã hiểu & Tuân lệnh',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xóa toàn bộ?',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          'Bạn sẽ mất sạch dữ liệu uống nước. Capy buồn lắm đó 🥺!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await NotificationService.cancelReminders();
              await (await SharedPreferences.getInstance()).clear();
              if (context.mounted)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final waterProvider = Provider.of<WaterProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hồ sơ & Cài đặt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: -20,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset('assets/images/capy_4.png', width: 150),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/capy_2.png', width: 180),
            ),
          ),

          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // THẺ HỒ SƠ
              const Text(
                'HỒ SƠ CỦA BẠN (Chạm để sửa)',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: AppTheme.oceanBlue.withOpacity(0.2)),
                ),
                child: InkWell(
                  onTap: () => _showEditProfile(context, waterProvider),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.lightBlue.withOpacity(0.3),
                          child: Image.asset(
                            'assets/images/capy_drink.gif',
                            height: 60,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          waterProvider.userName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.oceanBlue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildProfileStat(
                              Icons.transgender,
                              'Giới tính',
                              waterProvider.gender,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            _buildProfileStat(
                              Icons.monitor_weight,
                              'Cân nặng',
                              '${waterProvider.weight} kg',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // CÀI ĐẶT ỨNG DỤNG
              const Text(
                'CÀI ĐẶT MỤC TIÊU',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.flag,
                        color: AppTheme.oceanBlue,
                      ),
                      title: const Text(
                        'Mục tiêu uống nước',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${waterProvider.dailyGoal} ml >',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => _showEditGoal(context, waterProvider),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ListTile(
                      leading: const Icon(
                        Icons.access_time,
                        color: AppTheme.oceanBlue,
                      ),
                      title: const Text(
                        'Giờ thức / Ngủ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${waterProvider.wakeTime} - ${waterProvider.sleepTime} >',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => _showEditSchedule(context, waterProvider),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ListTile(
                      leading: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: AppTheme.oceanBlue,
                      ),
                      title: const Text(
                        'Giao diện Tối',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        activeColor: AppTheme.oceanBlue,
                        onChanged: (val) => themeProvider.toggleTheme(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // NHẮC UỐNG NƯỚC
              const Text(
                'NHẮC UỐNG NƯỚC',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        waterProvider.reminderEnabled
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: AppTheme.oceanBlue,
                      ),
                      title: const Text(
                        'Nhắc uống nước',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        waterProvider.reminderEnabled
                            ? '${ReminderScheduler.buildReminderMinutes(wakeTime: waterProvider.wakeTime, sleepTime: waterProvider.sleepTime, intervalMinutes: waterProvider.reminderInterval).length} lần/ngày, từ lúc thức đến lúc ngủ'
                            : 'Đang tắt',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Switch(
                        value: waterProvider.reminderEnabled,
                        activeColor: AppTheme.oceanBlue,
                        onChanged: (val) =>
                            waterProvider.setReminderEnabled(val),
                      ),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ListTile(
                      enabled: waterProvider.reminderEnabled,
                      leading: const Icon(
                        Icons.timer,
                        color: AppTheme.oceanBlue,
                      ),
                      title: const Text(
                        'Nhắc mỗi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${_formatInterval(waterProvider.reminderInterval)} >',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => _showIntervalSheet(context, waterProvider),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ListTile(
                      leading: const Icon(
                        Icons.send,
                        color: AppTheme.oceanBlue,
                      ),
                      title: const Text(
                        'Gửi thử thông báo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Kiểm tra xem máy đã nhận được thông báo chưa',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () =>
                          _sendTestNotification(context, waterProvider),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // THÔNG TIN DEV
              const Text(
                'THÔNG TIN',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(
                        Icons.developer_board,
                        color: AppTheme.oceanBlue,
                      ),
                      title: Text(
                        'Nhà phát triển',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Đặng Minh Phú (Phuhot)'),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    const ListTile(
                      leading: Icon(Icons.email, color: AppTheme.oceanBlue),
                      title: Text(
                        'Liên hệ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('minhphu050926@gmail.com'),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),

                    // === 🚑 ĐÃ THÊM MỤC TESTER Ở ĐÂY NÈ ===
                    const ListTile(
                      leading: Icon(
                        Icons.bug_report, // Icon con bọ chuyên trị bug
                        color: AppTheme.oceanBlue,
                      ),
                      title: Text(
                        'Tester',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Bảo Lộc & Minh Phú'),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),

                    // =====================================
                    ListTile(
                      leading: const Icon(
                        Icons.verified_user,
                        color: AppTheme.oceanBlue,
                      ),
                      title: const Text(
                        'Điều khoản sử dụng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Uống đủ nước, Capy sẽ bảo vệ bạn!'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () => _showTermsDialog(context),
                    ),

                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Xóa dữ liệu & Reset',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _confirmResetApp(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.oceanBlue,
            fontSize: 16,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
