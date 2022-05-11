class StepCount {
  final DateTime savedTime;
  final int stepCount;

  StepCount({required this.savedTime, required this.stepCount});
}

class StepCountSeries {
  final List<StepCount> stepCounts;

  DateTime get begin => stepCounts.first.savedTime;
  DateTime get end => stepCounts.last.savedTime;

  StepCountSeries({required this.stepCounts});

  StepCountSeries.fromJson(List<dynamic> json)
      : stepCounts = json.map((e) {
          return StepCount(
            savedTime: DateTime.fromMillisecondsSinceEpoch(e['date'] as int),
            stepCount: e['stepcount'] as int,
          );
        }).toList();
}

class StepCountResponse {
  final StepCountSeries series;
  final String? question;
  final DateTime dateTime;
  final StepCountSeries? comparison;

  StepCountResponse(this.series, {this.question, this.comparison}) : dateTime = DateTime.now();
}
