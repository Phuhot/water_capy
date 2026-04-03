import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/water_provider.dart';
import '../utils/app_theme.dart';
import '../utils/ui_helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _capyTips = [
    'Uống nước đều đặn giúp da đẹp lắm đó nha 🐹',
    'Nước lọc là chân ái! Trà sữa coi chừng mập đó!',
    'Một ngụm nước mát làm sảng khoái cả ngày dài!',
    'Capy đang khát, cho Capy uống miếng nước đi!',
    'Cố lên, bạn đang làm rất tốt!',
  ];

  late String _currentTip;
  final List<int> _cupOptions = [100, 150, 200, 250, 300, 500, 1000];
  double _capyScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentTip = _capyTips[Random().nextInt(_capyTips.length)];
  }

  // Tạo lịch uống dựa trên Giờ Thức / Giờ Ngủ của Cài đặt
  List<DateTime> _generateUpcomingSchedule(WaterProvider provider) {
    List<DateTime> schedule = [];
    DateTime now = DateTime.now();
    int wakeHour = int.parse(provider.wakeTime.split(':')[0]);
    int sleepHour = int.parse(provider.sleepTime.split(':')[0]);

    for (int i = 1; i <= 3; i++) {
      DateTime nextTime = now.add(Duration(minutes: 90 * i));
      bool isAwake = (wakeHour < sleepHour)
          ? (nextTime.hour >= wakeHour && nextTime.hour < sleepHour)
          : (nextTime.hour >= wakeHour ||
                nextTime.hour < sleepHour); // Ngủ xuyên đêm

      if (isAwake) schedule.add(nextTime);
    }
    return schedule;
  }

  IconData _getIconForCup(int amount) {
    if (amount <= 200) return Icons.local_drink;
    if (amount <= 400) return Icons.coffee;
    return Icons.sports_bar;
  }

  void _showCupSelectionSheet(BuildContext context, WaterProvider provider) {
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
                'Chọn dung tích cốc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: _cupOptions.map((amount) {
                  bool isSelected = provider.selectedCupAmount == amount;
                  return GestureDetector(
                    onTap: () {
                      provider.selectCup(amount);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.oceanBlue
                            : AppTheme.oceanBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.oceanBlue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getIconForCup(amount),
                            color: isSelected
                                ? Colors.white
                                : AppTheme.oceanBlue,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${amount}ml',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Water Capy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<WaterProvider>(
          builder: (context, waterProvider, child) {
            int percentage = waterProvider.dailyGoal > 0
                ? ((waterProvider.currentWater / waterProvider.dailyGoal) * 100)
                      .toInt()
                : 0;

            return Stack(
              children: [
                Positioned(
                  top: -20,
                  left: -20,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.08,
                      child: Image.asset(
                        'assets/images/capy_1.png',
                        width: 130,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 250,
                  right: -30,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.06,
                      child: Image.asset(
                        'assets/images/capy_2.png',
                        width: 110,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 200,
                  left: -30,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.05,
                      child: Image.asset(
                        'assets/images/capy_3.png',
                        width: 100,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  right: -20,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.08,
                      child: Image.asset(
                        'assets/images/capy_4.png',
                        width: 140,
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    const SizedBox(height: 10),

                    // === THANH STREAK 7 NGÀY SIÊU CUTE ===
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: waterProvider.last7DaysStreak.map((dayData) {
                          bool achieved = dayData['achieved'];
                          return Column(
                            children: [
                              // Filter xám xịt nếu chưa uống nước
                              ColorFiltered(
                                colorFilter: achieved
                                    ? const ColorFilter.mode(
                                        Colors.transparent,
                                        BlendMode.multiply,
                                      )
                                    : const ColorFilter.matrix(<double>[
                                        0.2126,
                                        0.7152,
                                        0.0722,
                                        0,
                                        0,
                                        0.2126,
                                        0.7152,
                                        0.0722,
                                        0,
                                        0,
                                        0.2126,
                                        0.7152,
                                        0.0722,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1,
                                        0,
                                      ]),
                                child: Opacity(
                                  opacity: achieved
                                      ? 1.0
                                      : 0.4, // Mờ đi nếu chưa uống
                                  child: Image.asset(
                                    'assets/images/capy_2.png',
                                    height: 35,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dayData['day'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: achieved
                                      ? AppTheme.oceanBlue
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CAPY CHAT BUBBLE
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade100,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Ê ${waterProvider.userName}! $_currentTip',
                        style: TextStyle(
                          color: Colors.brown.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // VÒNG TRÒN NƯỚC
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: waterProvider.progress,
                            ),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) =>
                                CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 15,
                                  backgroundColor: AppTheme.lightBlue
                                      .withOpacity(0.2),
                                  color: AppTheme.oceanBlue,
                                  strokeCap: StrokeCap.round,
                                ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              scale: _capyScale,
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              child: Image.asset(
                                'assets/images/capy_drink.gif',
                                height: 70,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${waterProvider.currentWater} ml',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.oceanBlue,
                              ),
                            ),
                            Text(
                              'Đạt $percentage%',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // KHU VỰC NẠP NƯỚC
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.9),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightBlue.withOpacity(
                                        0.2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getIconForCup(
                                        waterProvider.selectedCupAmount,
                                      ),
                                      color: AppTheme.oceanBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Cốc hiện tại',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${waterProvider.selectedCupAmount} ml',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.oceanBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () => _showCupSelectionSheet(
                                  context,
                                  waterProvider,
                                ),
                                icon: const Icon(
                                  Icons.sync,
                                  color: AppTheme.oceanBlue,
                                ),
                                label: const Text(
                                  'Đổi cốc',
                                  style: TextStyle(
                                    color: AppTheme.oceanBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: AppTheme.oceanBlue
                                      .withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          InkWell(
                            onTap: () {
                              int amount = waterProvider.selectedCupAmount;
                              waterProvider.addWater(amount);
                              setState(() {
                                _currentTip =
                                    _capyTips[Random().nextInt(
                                      _capyTips.length,
                                    )];
                                _capyScale = 1.3;
                              });
                              Future.delayed(
                                const Duration(milliseconds: 150),
                                () {
                                  if (mounted) setState(() => _capyScale = 1.0);
                                },
                              );

                              // === ĐÃ GỌI POPUP KHUNG CHAT Ở ĐÂY THAY VÌ SNACKBAR ===
                              showCapyDrinkPopup(context, amount);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: AppTheme.oceanBlue,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.oceanBlue.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.water_drop,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'UỐNG ${waterProvider.selectedCupAmount} ML',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // LỊCH UỐNG KHOA HỌC
                    Container(
                      height: 150,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10, left: 24),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Lịch uống tiếp theo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              children: _generateUpcomingSchedule(waterProvider)
                                  .map((time) => _buildScheduleItem(time))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScheduleItem(DateTime time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.alarm, size: 16, color: AppTheme.oceanBlue),
              SizedBox(width: 8),
              Text('Nạp nước thôi!', style: TextStyle(fontSize: 13)),
            ],
          ),
          Text(
            '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.oceanBlue,
            ),
          ),
        ],
      ),
    );
  }
}
