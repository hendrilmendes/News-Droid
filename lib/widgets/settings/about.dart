import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:newsdroid/screens/about/about.dart';

Widget buildAboutSettings(BuildContext context) {
  return ListTile(
    title: Text(AppLocalizations.of(context)!.about),
    subtitle: Text(AppLocalizations.of(context)!.aboutSub),
    leading: const Icon(Icons.info_outline),
    tileColor: Theme.of(context).listTileTheme.tileColor,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutPage()),
      );
    },
  );
}
