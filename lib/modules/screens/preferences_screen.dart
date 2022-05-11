import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:settings_ui/settings_ui.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final storage = GetStorage();
  String? uiPrefers;

  @override
  void initState() {
    super.initState();

    uiPrefers = storage.read('ui-prefers') ?? 'chatty';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('설정'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: SettingsList(
            sections: [
              SettingsSection(title: const Text('UI'), tiles: [
                SettingsTile.switchTile(
                  leading: const Icon(Icons.ad_units),
                  title: const Text('클래식 뷰 사용'),
                  initialValue: uiPrefers == 'classic',
                  onToggle: (value) {
                    setState(() {
                      uiPrefers = value ? 'classic' : 'chatty';
                    });
                    storage.write('ui-prefers', uiPrefers);
                  },
                )
              ])
            ],
          ),
        ));
  }
}
