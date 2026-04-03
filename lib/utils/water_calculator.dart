class WaterCalculator {
  /// Hàm tính lượng nước cần uống mỗi ngày (ml)
  static int calculateDailyGoal({
    required double weightKg,
    required int age,
    required String activityLevel, // 'low', 'medium', 'high'
  }) {
    // 1. Công thức cơ bản: 35ml / 1kg
    double baseWater = weightKg * 35.0;

    // 2. Điều chỉnh theo tuổi
    if (age > 55) {
      baseWater = weightKg * 30.0;
    } else if (age < 18) {
      baseWater = weightKg * 40.0;
    }

    // 3. Điều chỉnh theo mức vận động
    double activityBonus = 0;

    switch (activityLevel.toLowerCase()) {
      case 'low':
        activityBonus = 0;
        break;
      case 'medium':
        activityBonus = 400;
        break;
      case 'high':
        activityBonus = 800;
        break;
      default:
        activityBonus = 0;
    }

    // Tổng lượng nước
    double totalWater = baseWater + activityBonus;

    // Làm tròn số
    return totalWater.round();
  }
}