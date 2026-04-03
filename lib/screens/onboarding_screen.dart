import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/water_provider.dart';
import '../utils/app_theme.dart';
import 'main_tab_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Dữ liệu người dùng
  final TextEditingController _nameController = TextEditingController();
  String _gender = 'Khác';
  double _weight = 50;
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 22, minute: 30);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      if (_currentPage == 0 && _nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cho Capy biết tên bạn nhé! 🐹'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/capyhoi.gif', height: 100),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: AppTheme.oceanBlue),
            const SizedBox(height: 16),
            Text(
              'Capy đang tính toán lịch trình cho ${_nameController.text.trim()}...',
              style: const TextStyle(
                color: AppTheme.pureWhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    int dailyGoal = (_weight * 35).toInt();
    await prefs.setInt('dailyGoal', dailyGoal);

    if (mounted) {
      final provider = Provider.of<WaterProvider>(context, listen: false);

      // 1. Cập nhật Profile (Tên, Giới tính, Cân nặng)
      String finalName = _nameController.text.trim().isEmpty
          ? 'Bạn'
          : _nameController.text.trim();
      await provider.updateProfile(finalName, _gender, _weight.toInt());

      // 🚑 2. Cập nhật mục tiêu lượng nước (Cái nãy anh em mình quên)
      await provider.updateGoal(dailyGoal);

      // 3. Dịch giờ thành chữ và lưu vào Provider
      String wakeStr =
          '${_wakeTime.hour.toString().padLeft(2, '0')}:${_wakeTime.minute.toString().padLeft(2, '0')}';
      String sleepStr =
          '${_sleepTime.hour.toString().padLeft(2, '0')}:${_sleepTime.minute.toString().padLeft(2, '0')}';

      await provider.updateSchedule(wakeStr, sleepStr);

      // 🚑 4. ĐỒNG BỘ LẠI TẤT CẢ DỮ LIỆU LẦN CUỐI
      await provider.loadData();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainTabScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // STICKERS
            Positioned(
              top: -20,
              left: -20,
              child: Opacity(
                opacity: 0.08,
                child: Image.asset('assets/images/capy_1.png', width: 130),
              ),
            ),
            Positioned(
              top: 40,
              right: -40,
              child: Opacity(
                opacity: 0.08,
                child: Image.asset('assets/images/capy_2.png', width: 140),
              ),
            ),
            Positioned(
              top: 150,
              left: 30,
              child: Opacity(
                opacity: 0.05,
                child: Image.asset('assets/images/capy_3.png', width: 80),
              ),
            ),
            Positioned(
              top: 250,
              right: 20,
              child: Opacity(
                opacity: 0.04,
                child: Image.asset('assets/images/capy_4.png', width: 90),
              ),
            ),
            Positioned(
              top: 380,
              left: -30,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset('assets/images/capy_2.png', width: 110),
              ),
            ),
            Positioned(
              top: 450,
              right: 40,
              child: Opacity(
                opacity: 0.05,
                child: Image.asset('assets/images/capy_1.png', width: 100),
              ),
            ),
            Positioned(
              bottom: 150,
              left: 20,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset('assets/images/capy_4.png', width: 100),
              ),
            ),
            Positioned(
              bottom: 50,
              right: -20,
              child: Opacity(
                opacity: 0.08,
                child: Image.asset('assets/images/capy_3.png', width: 150),
              ),
            ),
            Positioned(
              bottom: -30,
              left: 60,
              child: Opacity(
                opacity: 0.07,
                child: Image.asset('assets/images/capy_1.png', width: 120),
              ),
            ),

            // Nội dung chính
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildNameStep(),
                      _buildGenderStep(),
                      _buildWeightStep(),
                      _buildSleepCycleStep(),
                    ],
                  ),
                ),

                // Thanh điều hướng
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          4,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 10,
                            width: _currentPage == index ? 24 : 10,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppTheme.oceanBlue
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.oceanBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _currentPage == 3 ? 'Hoàn tất' : 'Tiếp tục',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === BƯỚC 1: HỎI TÊN ===
  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/capy_drink.gif', height: 120),
          const SizedBox(height: 32),
          const Text(
            'Xin chào!\nCapy nên gọi bạn là gì nhỉ?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.oceanBlue,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập tên của bạn...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppTheme.oceanBlue,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.secondary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  // === BƯỚC 2: CHỌN GIỚI TÍNH ===
  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/capy_1.png', height: 120),
          const SizedBox(height: 32),
          Text(
            'Tuyệt vời, ${_nameController.text.isNotEmpty ? _nameController.text : "bạn"}!\nGiới tính của bạn là gì?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGenderButton('Nam', Icons.male),
              _buildGenderButton('Nữ', Icons.female),
              _buildGenderButton('Khác', Icons.transgender),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String title, IconData icon) {
    bool isSelected = _gender == title;
    return GestureDetector(
      onTap: () => setState(() => _gender = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.oceanBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.oceanBlue, width: 2),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.oceanBlue,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.oceanBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === BƯỚC 3: CHỌN CÂN NẶNG ===
  Widget _buildWeightStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/capy_2.png', height: 120),
          const SizedBox(height: 32),
          const Text(
            'Cân nặng của bạn?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Để Capy tính toán lượng nước phù hợp nhé',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          Text(
            '${_weight.toInt()} kg',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppTheme.oceanBlue,
            ),
          ),
          Slider(
            value: _weight,
            min: 30,
            max: 150,
            activeColor: AppTheme.oceanBlue,
            inactiveColor: AppTheme.lightBlue.withOpacity(0.3),
            onChanged: (value) => setState(() => _weight = value),
          ),
        ],
      ),
    );
  }

  // === BƯỚC 4: GIỜ THỨC / NGỦ ===
  Widget _buildSleepCycleStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/capy_4.png', height: 120),
          const SizedBox(height: 32),
          const Text(
            'Thời gian sinh hoạt?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Giúp Capy lên lịch nhắc nhở khoa học nhất',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            leading: const Icon(Icons.wb_sunny, color: Colors.orange),
            title: const Text(
              'Giờ thức dậy',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              _wakeTime.format(context),
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.oceanBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _wakeTime,
              );
              if (time != null) setState(() => _wakeTime = time);
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            leading: const Icon(Icons.nights_stay, color: Colors.indigo),
            title: const Text(
              'Giờ đi ngủ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              _sleepTime.format(context),
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.oceanBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _sleepTime,
              );
              if (time != null) setState(() => _sleepTime = time);
            },
          ),
        ],
      ),
    );
  }
}
