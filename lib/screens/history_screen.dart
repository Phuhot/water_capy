import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/water_provider.dart';
import '../utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isWeeklyView = true;

  // --- CÁC HÀM XỬ LÝ DỮ LIỆU BIỂU ĐỒ ---
  List<double> _getWeeklyData(List<Map<String, dynamic>> logs) {
    List<double> data = List.filled(7, 0.0);
    DateTime todayDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    for (var log in logs) {
      DateTime logTime = DateTime.parse(log['time']);
      DateTime logDate = DateTime(logTime.year, logTime.month, logTime.day);
      int dayDiff = todayDate.difference(logDate).inDays;

      if (dayDiff >= 0 && dayDiff < 7) {
        data[6 - dayDiff] += log['amount'];
      }
    }
    return data;
  }

  List<double> _getTodayData(List<Map<String, dynamic>> logs) {
    List<double> data = List.filled(4, 0.0);
    String todayStr = DateTime.now().toIso8601String().split('T')[0];

    for (var log in logs) {
      if ((log['time'] as String).startsWith(todayStr)) {
        DateTime logTime = DateTime.parse(log['time']);
        int hour = logTime.hour;
        if (hour >= 0 && hour < 6)
          data[0] += log['amount'];
        else if (hour >= 6 && hour < 12)
          data[1] += log['amount'];
        else if (hour >= 12 && hour < 18)
          data[2] += log['amount'];
        else
          data[3] += log['amount'];
      }
    }
    return data;
  }

  String _getDayName(int offset) {
    DateTime date = DateTime.now().subtract(Duration(days: offset));
    switch (date.weekday) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  // --- THUẬT TOÁN TÍNH TOÁN BÁO CÁO TRUNG BÌNH ---
  Map<String, dynamic> _calculateAdvancedStats(
    List<Map<String, dynamic>> logs,
    int dailyGoal,
  ) {
    if (logs.isEmpty) return {'avgWater': 0, 'avgFreq': 0, 'completion': 0};

    Map<String, int> dailyTotals = {};
    Map<String, int> dailyCounts = {};

    for (var log in logs) {
      String date = (log['time'] as String).split('T')[0];
      dailyTotals[date] = (dailyTotals[date] ?? 0) + (log['amount'] as int);
      dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
    }

    int totalWater = 0;
    int totalFreq = 0;
    int daysAchieved = 0;
    int totalActiveDays = dailyTotals.length;

    dailyTotals.forEach((date, total) {
      totalWater += total;
      if (total >= dailyGoal) daysAchieved++;
    });

    dailyCounts.forEach((date, count) {
      totalFreq += count;
    });

    return {
      'avgWater': (totalWater / totalActiveDays).round(),
      'avgFreq': (totalFreq / totalActiveDays).round(),
      'completion': ((daysAchieved / totalActiveDays) * 100).round(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Thống Kê',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<WaterProvider>(
        builder: (context, provider, child) {
          final chartData = _isWeeklyView
              ? _getWeeklyData(provider.dailyLogs)
              : _getTodayData(provider.dailyLogs);
          final double maxY = _isWeeklyView
              ? (provider.dailyGoal * 1.5)
              : (provider.dailyGoal * 0.8);

          final stats = _calculateAdvancedStats(
            provider.dailyLogs,
            provider.dailyGoal,
          );

          return Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset('assets/images/capy_1.png', width: 100),
                ),
              ),
              Positioned(
                top: 250,
                right: -20,
                child: Opacity(
                  opacity: 0.06,
                  child: Image.asset('assets/images/capy_2.png', width: 130),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -30,
                child: Opacity(
                  opacity: 0.08,
                  child: Image.asset('assets/images/capy_3.png', width: 150),
                ),
              ),
              Positioned(
                bottom: -10,
                right: 30,
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset('assets/images/capy_4.png', width: 90),
                ),
              ),

              ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  // 1. CÔNG TẮC CHUYỂN NGÀY/TUẦN
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isWeeklyView = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isWeeklyView
                                    ? AppTheme.oceanBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'Hôm nay',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !_isWeeklyView
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isWeeklyView = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isWeeklyView
                                    ? AppTheme.oceanBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '7 Ngày qua',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isWeeklyView
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 2. BIỂU ĐỒ NƯỚC
                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY > 0 ? maxY : 2000,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.toInt()} ml',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                String text = '';
                                bool isHighlight = false;

                                if (_isWeeklyView) {
                                  int daysAgo = 6 - index;
                                  isHighlight = daysAgo == 0;
                                  text = isHighlight
                                      ? 'Nay'
                                      : _getDayName(daysAgo);
                                } else {
                                  List<String> labels = [
                                    '0-6h',
                                    '6-12h',
                                    '12-18h',
                                    '18-24h',
                                  ];
                                  text = labels[index];
                                  isHighlight = true;
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      color: isHighlight
                                          ? AppTheme.oceanBlue
                                          : Colors.grey,
                                      fontWeight: isHighlight
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(chartData.length, (index) {
                          bool isTodayColumn = _isWeeklyView && index == 6;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: chartData[index],
                                color: isTodayColumn
                                    ? AppTheme.oceanBlue
                                    : AppTheme.lightBlue,
                                width: _isWeeklyView ? 16 : 24,
                                borderRadius: BorderRadius.circular(8),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxY,
                                  color: AppTheme.oceanBlue.withOpacity(0.05),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 3. BÁO CÁO TRUNG BÌNH
                  const Text(
                    'Báo cáo tổng quan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(
                        context,
                        'Trung bình',
                        '${stats['avgWater']} ml',
                        Icons.data_usage,
                        AppTheme.oceanBlue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context,
                        'Tần suất',
                        '${stats['avgFreq']} lần/ngày',
                        Icons.repeat,
                        Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context,
                        'Đạt mục tiêu',
                        '${stats['completion']}%',
                        Icons.emoji_events,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 4. LỊCH SỬ UỐNG NƯỚC
                  const Text(
                    'Lịch sử nạp nước',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  provider.dailyLogs.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Capy chưa thấy bạn uống ngụm nào cả 🥺',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.dailyLogs.length,
                          itemBuilder: (context, index) {
                            final log = provider.dailyLogs[index];
                            final time = DateTime.parse(log['time']);
                            final isToday = time.day == DateTime.now().day;
                            final dateStr = isToday
                                ? 'Hôm nay'
                                : '${time.day}/${time.month}';
                            final timeStr =
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.oceanBlue.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.water_drop,
                                    color: AppTheme.oceanBlue,
                                  ),
                                ),
                                title: Text(
                                  '+${log['amount']} ml',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.oceanBlue,
                                  ),
                                ),
                                subtitle: Text(
                                  dateStr,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Text(
                                  timeStr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
