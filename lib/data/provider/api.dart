import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:visualization_app/data/model/model.dart';

var baseUrl = '192.168.0.100:8000';

class ApiClient {
  final http.Client httpClient;

  ApiClient() : httpClient = http.Client();

  Future<StepCountResponse> getStepCount(DateTime begin, DateTime end) async {
    final dateFormat = DateFormat('yyyy-MM-dd');

    final response = json.decode((await httpClient.get(Uri.http(baseUrl, '/get_stepcount/', {
      'begin': dateFormat.format(begin),
      'end': dateFormat.format(end),
    })))
        .body);
    return StepCountResponse(
      StepCountSeries.fromJson(response['data'] as List<dynamic>),
      comparison: response['compare_with'] == null ? null : StepCountSeries.fromJson(response['compare_with'] as List<dynamic>),
    );
  }

  Future<StepCountResponse> getStepCountWithComparison(
      DateTime begin, DateTime end, DateTime comparisonBegin, DateTime comparisonEnd) async {
    final dateFormat = DateFormat('yyyy-MM-dd');

    final response1 = json.decode((await httpClient.get(Uri.http(baseUrl, '/get_stepcount/', {
      'begin': dateFormat.format(begin),
      'end': dateFormat.format(end),
    })))
        .body);
    final response2 = json.decode((await httpClient.get(Uri.http(baseUrl, '/get_stepcount/', {
      'begin': dateFormat.format(comparisonBegin),
      'end': dateFormat.format(comparisonEnd),
    })))
        .body);

    return StepCountResponse(
      StepCountSeries.fromJson(response1['data'] as List<dynamic>),
      comparison: StepCountSeries.fromJson(response2['data'] as List<dynamic>),
    );
  }

  Future<StepCountResponse> doQuestion(String question) async {
    final response = await httpClient.post(Uri.http(baseUrl, '/chat_service/'), body: {
      'input1': question,
    });
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return StepCountResponse(
      StepCountSeries.fromJson(jsonResponse['data'] as List<dynamic>),
      question: question,
      comparison: jsonResponse['compare_with'] == null ? null : StepCountSeries.fromJson(jsonResponse['compare_with'] as List<dynamic>),
    );
  }
}
