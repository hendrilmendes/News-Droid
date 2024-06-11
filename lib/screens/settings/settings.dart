import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iconsax/iconsax.dart';
import 'package:newsdroid/auth/auth.dart';
import 'package:newsdroid/theme/theme.dart';
import 'package:newsdroid/widgets/settings/about.dart';
import 'package:newsdroid/widgets/settings/accounts.dart';
import 'package:newsdroid/widgets/settings/category.dart';
import 'package:newsdroid/widgets/settings/notification.dart';
import 'package:newsdroid/widgets/settings/review.dart';
import 'package:newsdroid/widgets/settings/support.dart';
import 'package:newsdroid/widgets/settings/theme.dart';
import 'package:newsdroid/widgets/settings/update.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final User? _user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        actions: [
          IconButton(
            color: Colors.blue,
            icon: const Icon(Icons.exit_to_app_outlined),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: AppLocalizations.of(context)!.desconect,
          ),
        ],
      ),
      body: ListView(
        children: [
          AccountUser(user: _user),
          const Divider(),
          buildCategoryHeader(
              AppLocalizations.of(context)!.notification, Iconsax.notification),
          const NotificationSettings(),
          buildCategoryHeader(
              AppLocalizations.of(context)!.interface, Iconsax.pen_tool),
          ThemeSettings(themeModel: themeModel),
          buildCategoryHeader(
              AppLocalizations.of(context)!.outhers, Iconsax.more),
          buildUpdateSettings(context),
          buildReviewSettings(context),
          buildSupportSettings(context),
          buildAboutSettings(context),
        ],
      ),
    );
  }
}
