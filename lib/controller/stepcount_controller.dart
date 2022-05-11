import 'package:get/get.dart';
import 'package:visualization_app/data/model/model.dart';
import 'package:visualization_app/data/provider/api.dart';

class StepCountController extends GetxController {
  final ApiClient api;

  StepCountController({required this.api});

  final history = <StepCountResponse>[].obs;
  StepCountResponse? get response => history.last;

  final pendingQuestions = <String>[].obs;

  Future<void> fetchStepCount(DateTime begin, DateTime end) async {
    final response = await api.getStepCount(begin, end);
    history.add(response);
  }

  Future<void> fetchStepCountWithComparison(DateTime begin, DateTime end, DateTime comparisonBegin, DateTime comparisonEnd) async {
    final response = await api.getStepCountWithComparison(begin, end, comparisonBegin, comparisonEnd);
    history.add(response);
  }

  void addQuestion(String question) {
    pendingQuestions.add(question);
    _doQuestion();
  }

  Future<void> _doQuestion() async {
    while (pendingQuestions.isNotEmpty) {
      final question = pendingQuestions.first;
      final response = await api.doQuestion(question);

      pendingQuestions.removeAt(0);
      history.add(response);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _doQuestion();
  }
}
