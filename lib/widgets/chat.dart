import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visualization_app/controller/stepcount_controller.dart';
import 'package:visualization_app/data/model/model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:visualization_app/widgets/chart.dart';

const enableVoiceInput = false;
const chatBackgroundColor = Color.fromARGB(255, 223, 223, 223);

class ChatList extends StatelessWidget {
  ChatList({Key? key}) : super(key: key);

  final stepCountController = Get.find<StepCountController>();
  final scrollController = ScrollController();

  // scroll down smooooth
  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      reverse: true,
      slivers: [
        // pending questions
        Obx(
          () => SliverList(
            delegate: SliverChildListDelegate(
              stepCountController.pendingQuestions.reversed
                  .map((question) => ChatBubble(
                        sendByMe: true,
                        child: Text(question),
                        pending: true,
                      ))
                  .toList(),
            ),
          ),
        ),

        // completed questions
        Obx(
          () => SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final reversedIndex = stepCountController.history.length - 1 - index;
                return Chat(response: stepCountController.history[reversedIndex]);
              },
              childCount: stepCountController.history.length,
            ),
          ),
        ),
      ],
    );
  }
}

class Chat extends StatelessWidget {
  final StepCountResponse response;

  const Chat({Key? key, required this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('M월 d일').format;
    final begin = format(response.series.begin);
    final end = format(response.series.end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        response.question == null
            ? null
            : ChatBubble(
                sendByMe: true,
                child: Text(response.question!),
                dateTime: response.dateTime,
              ),
        ChatBubble(
          sendByMe: false,
          child: Text('$begin ~ $end 걸음 수 입니다.'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 10),
          child: SizedBox(
            width: 280,
            height: 240,
            child: StepCountBarChart(series: response.series),
          ),
        ),
      ].whereType<Widget>().toList(),
    );
  }
}

const colorSendByMe = Color(0xFFA6CD4E);
const colorSendByOther = Color(0xFFFFFFFF);
var sendDateFormat = DateFormat('h:mm');

class ChatBubble extends StatelessWidget {
  final bool sendByMe;
  final Widget child;
  final bool pending;
  final DateTime? dateTime;

  const ChatBubble({Key? key, required this.sendByMe, required this.child, this.pending = false, this.dateTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe ? const EdgeInsets.only(left: 30) : const EdgeInsets.only(right: 30),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(23),
                topRight: const Radius.circular(23),
                bottomLeft: sendByMe ? const Radius.circular(23) : Radius.zero,
                bottomRight: sendByMe ? Radius.zero : const Radius.circular(23)),
            color: sendByMe ? colorSendByMe : colorSendByOther,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 0.5,
                blurRadius: 5,
              )
            ]),
        child: Column(
          crossAxisAlignment: sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            child,
            ...(sendByMe
                ? [
                    const SizedBox(height: 4),
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        children: pending
                            ? [
                                const Text(
                                  '전송중 ...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ]
                            : [
                                Text(
                                  dateTime == null ? '' : sendDateFormat.format(dateTime!),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.done_all, color: Colors.black54, size: 14),
                              ]),
                  ]
                : []),
          ],
        ),
      ),
    );
  }
}

class ChatInput extends StatefulWidget {
  final Function(String) onSend;

  const ChatInput({Key? key, required this.onSend}) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

const sendButtonColor = Color(0xFFA9CD34);

class _ChatInputState extends State<ChatInput> {
  final textEditingController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _listening = false;
  String? _recognizedWords;

  @override
  void initState() {
    super.initState();

    textEditingController.addListener(() {
      setState(() {}); // update ui when user types text
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _onSpeech() async {
    final available = await _speech.initialize();
    if (!available) return;

    if (!_listening) {
      log('Listening user speech ...');

      _speech.listen(onResult: (result) {
        log('User speech: ' + result.recognizedWords);
        _recognizedWords = result.recognizedWords;
      });
    } else {
      log('Stopped listening');
      log('User says: ' + _recognizedWords!);
      _speech.stop();
      _recognizedWords = null;
    }

    setState(() {
      _listening = !_listening;
    });
  }

  void _onSend() {
    if (textEditingController.text.isEmpty) return;

    widget.onSend(textEditingController.text);

    setState(() {
      textEditingController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        height: 50,
        decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(
            color: Color(0xFFD9D9D9),
            width: 1,
          )),
          //color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: textEditingController,
                decoration: const InputDecoration(
                    hintText: '메세지를 입력하세요', hintStyle: TextStyle(color: Colors.white, fontSize: 20), border: InputBorder.none),
                onSubmitted: (value) => _onSend(),
              ),
            ),
            const SizedBox(width: 16),
            enableVoiceInput
                ? SizedBox(
                    width: 50,
                    child: Container(
                      color: Colors.transparent,
                      child: IconButton(
                        color: _listening ? Colors.red : Colors.black54,
                        icon: const Icon(Icons.mic),
                        onPressed: _onSpeech,
                      ),
                    ),
                  )
                : null,
            Material(
              color: textEditingController.text.isEmpty == true ? Colors.transparent : sendButtonColor,
              child: InkWell(
                child: SizedBox(
                  width: 50,
                  child: textEditingController.text.isEmpty == true
                      ? const Icon(Icons.circle, size: 6)
                      : const Icon(Icons.keyboard_arrow_right, size: 26),
                ),
                onTap: textEditingController.text.isEmpty ? null : _onSend,
              ),
            ),
          ].whereType<Widget>().toList(),
        ),
      ),
    );
  }
}
