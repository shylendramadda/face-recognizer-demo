import 'package:flutter/material.dart';
import 'package:fr_demo/data/local/preference_utils.dart';
import 'package:fr_demo/utils/app_colors.dart';
import 'package:fr_demo/utils/app_constants.dart';
import 'package:fr_demo/utils/app_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      urlController.text = await getURL();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.settings),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Text(
            AppConstants.enterURL,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'Enter a URL here',
                labelText: 'BASE URL*',
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Container(
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.secondary)),
                  onPressed: () => _saveURL(urlController.text),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void _saveURL(String url) {
    if (url.isNotEmpty &&
        !(url.startsWith('http') && url.startsWith('https'))) {
      AppConstants.baseUrl = url;
      PreferenceUtils.setString(AppConstants.url, url);
      AppUtils.showToast('URL Updated');
    } else {
      AppUtils.showToast('Enter a valid URL');
    }
  }

  Future<String> getURL() async {
    return PreferenceUtils.getString(AppConstants.url, defaultValue: '') ?? '';
  }
}
