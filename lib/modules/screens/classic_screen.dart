import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visualization_app/controller/stepcount_controller.dart';
import 'package:visualization_app/widgets/chart.dart';
import 'package:visualization_app/widgets/classic.dart';

DateFormat dateFormat = DateFormat('M월 d일');

rangeButtonStyle(Color color) => ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      fixedSize: MaterialStateProperty.all<Size>(const Size.fromWidth(250)),
      elevation: MaterialStateProperty.all<double>(0.0),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.black87),
      backgroundColor: MaterialStateProperty.all<Color>(color),
      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0)),
    );

class ClassicScreen extends StatelessWidget {
  ClassicScreen({Key? key}) : super(key: key);

  final controller = Get.find<StepCountController>();

  @override
  Widget build(BuildContext context) {
    return ClassicFixedRangeScreen();
  }
}

class ClassicFixedRangeScreen extends StatefulWidget {
  ClassicFixedRangeScreen({Key? key}) : super(key: key);

  final stepCountController = Get.find<StepCountController>();

  @override
  _ClassicFixedRangeScreenState createState() => _ClassicFixedRangeScreenState();
}

class _ClassicFixedRangeScreenState extends State<ClassicFixedRangeScreen> with TickerProviderStateMixin {
  DurationUnit durationUnit = DurationUnit.week;
  late TabController tabController;

  int durationOffsetFromCurrent = 0;

  DateTimeRange get range {
    final now = DateTime.now();
    late DateTime start, end;

    switch (durationUnit) {
      case DurationUnit.week:
        start = DateTime(now.year, now.month, (now.day - now.weekday % 7) + 1 + durationOffsetFromCurrent * 7);
        break;
      case DurationUnit.month:
        start = DateTime(now.year, now.month + durationOffsetFromCurrent, 1);
        break;
      case DurationUnit.year:
        start = DateTime(now.year + durationOffsetFromCurrent, 1, 1);
        break;
    }

    switch (durationUnit) {
      case DurationUnit.week:
        end = DateTime(start.year, start.month, start.day + 7 - 1);
        break;
      case DurationUnit.month:
        end = DateTime(start.year, start.month + 1, 0);
        break;
      case DurationUnit.year:
        end = DateTime(start.year + 1, 0, 1);
        break;
    }

    return DateTimeRange(
      start: start,
      end: end,
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    onRangeChange(range);
  }

  void onRangeChange(DateTimeRange range) {
    widget.stepCountController.fetchStepCount(range.start, range.end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('걸음 수'),
        centerTitle: true,
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.more_vert),
          // ),
          PopupMenuButton<String>(
            onSelected: (choice) {
              switch (choice) {
                case '기간 설정':
                  Get.to(() => ClassicDynamicRangeScreen(defaultRange: range))?.then((_) {
                    onRangeChange(range);
                  });
                  break;
                case '비교':
                  Get.to(() => ClassicDynamicRangeScreen(defaultRange: range, withComparison: true))?.then((_) {
                    onRangeChange(range);
                  });
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return ['기간 설정', '비교']
                  .map((choice) => PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      ))
                  .toList();
            },
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          onTap: (tabIndex) => setState(() {
            durationUnit = DurationUnit.values[tabIndex];
            durationOffsetFromCurrent = 0;
            onRangeChange(range);
          }),
          tabs: DurationUnit.values.map((unit) => Tab(text: unit.label)).toList(),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date Range adjust widget
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // left button
                IconButton(
                  onPressed: () => setState(() {
                    durationOffsetFromCurrent--;
                    onRangeChange(range);
                  }),
                  icon: const Icon(Icons.chevron_left),
                ),
                // main value
                Text('${dateFormat.format(range.start)} ~ ${dateFormat.format(range.end)}',
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                // right button
                IconButton(
                  onPressed: () => setState(() {
                    durationOffsetFromCurrent++;
                    onRangeChange(range);
                  }),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // chart widget
            Obx(() => widget.stepCountController.history.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 300,
                      child: Obx(() => StepCountBarChart(series: widget.stepCountController.history.last.series)),
                    ))
                : const Text('로딩중 ...')),
          ],
        ),
      ),
    );
  }
}

class ClassicDynamicRangeScreen extends StatefulWidget {
  final DateTimeRange defaultRange;
  final bool withComparison;

  final stepCountController = Get.find<StepCountController>();

  ClassicDynamicRangeScreen({required this.defaultRange, this.withComparison = false, Key? key}) : super(key: key);

  @override
  _ClassicDynamicRangeScreenState createState() => _ClassicDynamicRangeScreenState();
}

class _ClassicDynamicRangeScreenState extends State<ClassicDynamicRangeScreen> {
  late DateTimeRange range;
  late DateTimeRange comparison;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    range = widget.defaultRange;

    if (!widget.withComparison) {
      widget.stepCountController.fetchStepCount(range.start, range.end).then((_) => setState(() {
            loaded = true;
          }));
    } else {
      comparison = DateTimeRange(
        start: DateTime(range.start.year, range.start.month, range.start.day - range.duration.inDays),
        end: DateTime(range.end.year, range.end.month, range.end.day - range.duration.inDays),
      );

      widget.stepCountController
          .fetchStepCountWithComparison(range.start, range.end, comparison.start, comparison.end)
          .then((_) => setState(() {
                loaded = true;
              }));
    }
  }

  void onRangeChange() {
    if (!widget.withComparison) {
      widget.stepCountController.fetchStepCount(range.start, range.end);
    } else {
      widget.stepCountController.fetchStepCountWithComparison(range.start, range.end, comparison.start, comparison.end);
    }
  }

  void _handleClickDateRange({bool isComparison = false}) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2022, 12, 31),
      initialDateRange: !isComparison ? range : comparison,
    );

    if (result != null) {
      setState(() {
        if (!isComparison) {
          range = result;
        } else {
          comparison = result;
        }
        onRangeChange();
      });
    }
  }

  Widget getChart() {
    if (!loaded) return const Text('로딩중 ...');

    if (!widget.withComparison) {
      return Obx(() => StepCountBarChart(
            series: widget.stepCountController.history.last.series,
          ));
    } else {
      if (widget.stepCountController.history.last.comparison == null) {
        return const Text('');
      }

      return Obx(() => StepCountLineChart(
            series: widget.stepCountController.history.last.series,
            comparison: widget.stepCountController.history.last.comparison!,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(!widget.withComparison ? '기간 설정' : '비교'),
        leading: const BackButton(),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              style: rangeButtonStyle(const Color(0xFFf4f9e8)),
              onPressed: _handleClickDateRange,
              child: Text(
                '${dateFormat.format(range.start)} ~ ${dateFormat.format(range.end)}',
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            ...(widget.withComparison
                ? [
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: rangeButtonStyle(const Color(0xFFedeff1)),
                      onPressed: () => _handleClickDateRange(isComparison: true),
                      child: Text(
                        '${dateFormat.format(comparison.start)} ~ ${dateFormat.format(comparison.end)}',
                        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    )
                  ]
                : []),
            const SizedBox(height: 10),
            Obx(() => widget.stepCountController.history.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 300,
                      child: getChart(),
                    ))
                : const Text('로딩중 ...')),
          ],
        ),
      ),
    );
  }
}
