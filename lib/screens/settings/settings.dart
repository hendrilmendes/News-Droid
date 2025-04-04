import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newsdroid/l10n/app_localizations.dart';
import 'package:newsdroid/theme/theme.dart';
import 'package:newsdroid/widgets/settings/about.dart';
import 'package:newsdroid/widgets/settings/accounts.dart';
import 'package:newsdroid/widgets/settings/dynamic_colors.dart';
import 'package:newsdroid/widgets/settings/notification.dart';
import 'package:newsdroid/widgets/settings/review.dart';
import 'package:newsdroid/widgets/settings/search.dart';
import 'package:newsdroid/widgets/settings/support.dart';
import 'package:newsdroid/widgets/settings/theme.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isAndroid12 = false;

  @override
  void initState() {
    super.initState();
    _checkAndroidVersion();
  }

  Future<void> _checkAndroidVersion() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final version = androidInfo.version.sdkInt;
      setState(() {
        _isAndroid12 = version >= 31;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          AccountUser(user: _user),
          const SizedBox(height: 8),
          _buildSectionCard(context, const NotificationSettings()),
          const SizedBox(height: 8),
          _buildSectionCard(
            context,
            Column(
              children: [
                ThemeSettings(themeModel: themeModel),
                SearchBarSetting(),
                if (_isAndroid12) const DynamicColorsSettings(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildSectionCard(
            context,
            Column(
              children: [
                buildReviewSettings(context),
                buildSupportSettings(context),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildSectionCard(
            context,
            Column(children: [buildAboutSettings(context)]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, Widget child) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).listTileTheme.tileColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [child],
      ),
    );
  }
}
