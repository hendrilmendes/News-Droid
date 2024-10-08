import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:newsdroid/theme/theme.dart';
import 'package:newsdroid/widgets/settings/about.dart';
import 'package:newsdroid/widgets/settings/accounts.dart';
import 'package:newsdroid/widgets/settings/category.dart';
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
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          AccountUser(user: _user),
          buildCategoryHeader(
              AppLocalizations.of(context)!.notification, Icons.notifications_active_outlined),
          const NotificationSettings(),
          buildCategoryHeader(
              AppLocalizations.of(context)!.interface, Icons.color_lens_outlined),
          ThemeSettings(themeModel: themeModel),
          SearchBarSetting(),
          buildCategoryHeader(
              AppLocalizations.of(context)!.outhers, Icons.more_horiz_outlined),
          buildUpdateSettings(context),
          buildReviewSettings(context),
          buildSupportSettings(context),
          buildAboutSettings(context),
        ],
      ),
    );
  }
}
