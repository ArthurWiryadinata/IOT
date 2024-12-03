import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For the pie chart

class FruitPieChart extends StatelessWidget {
  final List<bool> isFall; // Accept a List<bool> directly

  const FruitPieChart({super.key, required this.isFall});

  @override
  Widget build(BuildContext context) {
    // Count the number of true (fallen) and false (not fallen) values
    int fallenFruits = isFall.where((value) => value).length;
    int notFallenFruits = isFall.where((value) => !value).length;

    // Prepare data for the pie chart
    final List<PieChartSectionData> pieSections = [
      PieChartSectionData(
        value: fallenFruits.toDouble(),
        color: Colors.green,
        title: "$fallenFruits",
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: notFallenFruits.toDouble(),
        color: Colors.red,
        title: "$notFallenFruits",
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ];

    return PieChart(
      PieChartData(
        sections: pieSections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
