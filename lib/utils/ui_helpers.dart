import 'package:flutter/material.dart';
import 'dart:math'; // Thêm thư viện này để dùng cho tính năng random câu thoại
import 'app_theme.dart';

// Đặt hàm ở ngoài class để có thể gọi trực tiếp từ bất kỳ đâu
void showCuteSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    // 1. Tắt hình nền và bóng mặc định đi để tự custom Container
    backgroundColor: Colors.transparent,
    elevation: 0,

    // 2. Hiệu ứng nổi (Floating) sẽ tự động có slide + fade in rất mượt
    behavior: SnackBarBehavior.floating,

    // 3. Tự động biến mất sau 2 giây
    duration: const Duration(seconds: 2),

    // 4. Custom giao diện
    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // Tự động nhận diện Dark/Light mode để đổi màu nền Snackbar
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A) // Xám đen nhám cho Dark Mode
            : AppTheme.pureWhite, // Trắng tinh khôi cho Light Mode

        borderRadius: BorderRadius.circular(24), // Bo góc tròn xoe
        border: Border.all(
          color: AppTheme.lightBlue.withOpacity(0.5),
          width: 2,
        ),

        // Hiệu ứng bóng đổ (Shadow) tạo chiều sâu 3D
        boxShadow: [
          BoxShadow(
            color: AppTheme.oceanBlue.withOpacity(0.15),
            blurRadius: 15, // Độ nhòe của bóng
            offset: const Offset(0, 8), // Hướng bóng đổ xuống dưới
          ),
        ],
      ),
      child: Row(
        children: [
          // Sticker Capy mini siêu mượt (Bạn có thể đổi thành capy_drink.gif)
          Image.asset('assets/images/capy_hello.gif', height: 36),
          const SizedBox(width: 12),

          // Nội dung thông báo
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.oceanBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),

          // Bonus: Icon giọt nước nhỏ xíu ở cuối
          const Text('💧', style: TextStyle(fontSize: 18)),
        ],
      ),
    ),
  );

  // Gọi lệnh hiển thị
  // Lệnh hideCurrentSnackBar giúp: Nếu user bấm thêm nước 3 lần liên tục,
  // nó sẽ ngay lập tức đổi thông báo thay vì chờ cái cũ biến mất.
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

// === TRÙM CUỐI: POPUP KHUNG CHAT NÂU NẰM NGANG CÓ ANIMATION TỰ TẮT ===
void showCapyDrinkPopup(BuildContext context, int amount) {
  final List<String> popupTips = [
    'Nước ngon quá! 🐹',
    'Sảng khoái ghê!',
    'Capy ưng cái bụng!',
    'Đã khát quá đi!',
    'Tuyệt vời! Tiếp tục nha!',
    'Ực ực... mát lạnh!',
  ];
  String randomTip = popupTips[Random().nextInt(popupTips.length)];

  showGeneralDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.2), // Làm mờ nền phía sau một chút
    barrierDismissible: true,
    barrierLabel: 'CapyPopup',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, anim1, anim2) {
      // Tự động đóng popup sau 1.5 giây để không làm gián đoạn người dùng
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });

      return SafeArea(
        child: Align(
          alignment: Alignment.center, // Hiện ngay giữa màn hình
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bé Capy bên trái
                Image.asset('assets/images/capy_drink.gif', height: 100),
                const SizedBox(width: 8),

                // Khung chat nâu bên phải (Đuôi chĩa về bên trái)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                        bottomLeft: Radius.circular(
                          0,
                        ), // Góc vuông tạo cảm giác đuôi khung chat
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+$amount ml',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: AppTheme.oceanBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          randomTip,
                          style: TextStyle(
                            color: Colors.brown.shade800,
                            fontSize: 14,
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
        ),
      );
    },
    // Hiệu ứng lò xo (Elastic) bung ra cực mượt
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: Curves.elasticOut.transform(anim1.value),
        child: Opacity(opacity: anim1.value, child: child),
      );
    },
  );
}
