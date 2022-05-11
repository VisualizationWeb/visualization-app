import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualization_app/data/model/model.dart';

const barColor = Color(0xFF728091);
const sideTitleTextStyle = TextStyle(color: Colors.black54, fontSize: 10);
var bottomTitleFormat = DateFormat('d');

class StepCountBarChart extends StatelessWidget {
  final StepCountSeries series;
  final StepCountSeries? comparison;

  const StepCountBarChart({Key? key, required this.series, this.comparison}) : super(key: key);

  List<BarChartGroupData> getData() {
    final barWidth = (() {
      switch (series.stepCounts.length ~/ 10) {
        case 0:
          return 12;
        case 1:
          return 8;
        default:
          return 4;
      }
    })()
        .toDouble();

    return series.stepCounts.asMap().entries.map((entry) {
      final index = entry.key;
      final origin = entry.value;
      final compare = comparison?.stepCounts[index];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: origin.stepCount.toDouble(),
            width: barWidth,
            borderRadius: const BorderRadius.all(Radius.zero),
            colors: [barColor],
          ),
          compare == null
              ? null
              : BarChartRodData(
                  toY: compare.stepCount.toDouble(),
                  borderRadius: const BorderRadius.all(Radius.zero),
                  colors: [barColor],
                )
        ].whereType<BarChartRodData>().toList(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(
          border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(
              width: 2,
              color: Colors.black54,
            ),
            bottom: BorderSide(
              width: 2,
              color: Colors.black54,
            ),
          ),
        ),
        alignment: BarChartAlignment.spaceAround,
        barGroups: getData(),
        gridData: FlGridData(
          show: false,
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: SideTitles(showTitles: false),
          rightTitles: SideTitles(showTitles: false),
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => sideTitleTextStyle,
            margin: 10,
          ),
          bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => sideTitleTextStyle,
              margin: 10,
              getTitles: (value) => bottomTitleFormat.format(series.begin.add(Duration(days: value.toInt())))),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              rod.toY.toInt().toString(),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StepCountLineChart extends StatelessWidget {
  final StepCountSeries series;
  final StepCountSeries comparison;

  const StepCountLineChart({Key? key, required this.series, required this.comparison}) : super(key: key);

  List<LineChartBarData> getData() {
    return [series, comparison].asMap().entries.map((entry) {
      final index = entry.key;
      final _series = entry.value;

      return LineChartBarData(
          isCurved: false,
          dotData: FlDotData(show: false),
          colors: [
            [const Color(0xFFa6cd4e), const Color(0xFF708090)].elementAt(index)
          ],
          spots: _series.stepCounts.asMap().entries.map((entry) {
            final index = entry.key;
            final origin = entry.value;

            return FlSpot(index.toDouble(), origin.stepCount.toDouble());
          }).toList());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(LineChartData(
      borderData: FlBorderData(
        border: const Border(
          top: BorderSide.none,
          right: BorderSide.none,
          left: BorderSide(
            width: 2,
            color: Colors.black54,
          ),
          bottom: BorderSide(
            width: 2,
            color: Colors.black54,
          ),
        ),
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: SideTitles(showTitles: false),
        rightTitles: SideTitles(showTitles: false),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => sideTitleTextStyle,
          margin: 10,
        ),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => sideTitleTextStyle,
          margin: 10,
          getTitles: (value) => DateFormat('E').format(series.begin.add(Duration(days: value.toInt()))),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(getTooltipItems: (touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            final flSpot = barSpot;

            return LineTooltipItem(
              flSpot.y.toInt().toString(),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            );
          }).toList();
        }),
      ),
      lineBarsData: getData(),
    ));
  }
}
