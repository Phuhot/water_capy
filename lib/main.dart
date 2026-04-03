import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'services/water_provider.dart';
import 'services/notification_service.dart';
import 'services/theme_provider.dart'; // Đã thêm
import 'utils/app_theme.dart';
import 'screens/main_tab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({Key? key, required this.isFirstTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WaterProvider()..loadData()),
        // KHỞI TẠO THÊM THEME PROVIDER
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
      ],
      // Dùng Consumer để lắng nghe sự thay đổi của Sáng/Tối
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Water Capy',
            debugShowCheckedModeBanner: false,
            // CẤU HÌNH THEME TỰ ĐỘNG CHUYỂN ĐỔI
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,

            home: isFirstTime
                ? const OnboardingScreen()
                : const MainTabScreen(),
          );
        },
      ),
    );
  }
}
