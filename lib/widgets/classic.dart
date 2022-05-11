enum DurationUnit {
  week,
  month,
  year,
}

extension DurationUnitExtension on DurationUnit {
  String get label {
    switch (this) {
      case DurationUnit.week:
        return '7일';
      case DurationUnit.month:
        return '1개월';
      case DurationUnit.year:
        return '12개월';
    }
  }
}
