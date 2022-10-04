import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


LineChartBarData historyLine(List<FlSpot> points, Color color_) {
  return LineChartBarData(
    spots: points,
    dotData: FlDotData(
      show: false,
    ),
    gradient: LinearGradient(
        colors: [color_.withOpacity(0), color_],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.1, 1.0]),
    barWidth: 4,
    isCurved: false,
  );
}
