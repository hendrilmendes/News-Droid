import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:newsdroid/theme/theme.dart';
import 'package:newsdroid/widgets/settings/about.dart';
import 'package:newsdroid/widgets/settings/accounts.dart';
import 'package:newsdroid/widgets/settings/notification.dart';
import 'package:newsdroid/widgets/settings/review.dart';
import 'package:newsdroid/widgets/settings/search.dart';
import 'package:newsdroid/widgets/settings/support.dart';
import 'package:newsdroid/widgets/settings/theme.dart';
import 'package:newsdroid/widgets/settings/update.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final User? _user = FirebaseAuth.instance.currentUser;

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
          _buildSectionCard(
            context,
            const NotificationSettings(),
          ),
          const SizedBox(height: 8),
          _buildSectionCard(
            context,
            Column(
              children: [
                ThemeSettings(themeModel: themeModel),
                SearchBarSetting(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildSectionCard(
            context,
            Column(
              children: [
                buildUpdateSettings(context),
                buildReviewSettings(context),
                buildSupportSettings(context),
                buildAboutSettings(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    Widget child,
  ) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).listTileTheme.tileColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
        ],
      ),
    );
  }
}
