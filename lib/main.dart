import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:visualization_app/controller/stepcount_controller.dart';
import 'package:visualization_app/data/provider/api.dart';
import 'package:visualization_app/modules/screens/main_screen.dart';
import 'package:visualization_app/modules/screens/preferences_screen.dart';

void main() async {
  // intialize storage
  await GetStorage.init();

  // initialize controllers
  Get.put(StepCountController(api: ApiClient()));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Visualization App',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        routes: {
          '/': (context) => const MainScreen(),
          '/preferences': (context) => const PreferencesScreen(),
        });
  }
}
