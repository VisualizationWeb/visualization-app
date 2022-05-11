import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visualization_app/controller/stepcount_controller.dart';
import 'package:visualization_app/widgets/chat.dart';

class ChattyScreen extends StatelessWidget {
  ChattyScreen({Key? key}) : super(key: key);

  final controller = Get.find<StepCountController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(child: ChatList()),
          ChatInput(onSend: (String question) {
            controller.addQuestion(question);
          }),
        ]),
      ),
    );
  }
}
