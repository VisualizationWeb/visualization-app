import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:visualization_app/modules/screens/chatty_screen.dart';
import 'package:visualization_app/modules/screens/classic_screen.dart';

const uiPrefers = 'classic';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //final storage = GetStorage();
  //String? uiPrefers;

  @override
  void initState() {
    super.initState();

    // they're two modes: chatty, classic
    //uiPrefers = storage.read('ui-prefers') ?? 'chatty';
  }

  @override
  Widget build(BuildContext context) {
    //return ChattyScreen();
    return uiPrefers == 'chatty' ? ChattyScreen() : ClassicScreen();
  }
}
