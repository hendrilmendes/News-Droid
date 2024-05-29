import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iconsax/iconsax.dart';
import 'package:newsdroid/screens/about/about.dart';

Widget buildAboutSettings(BuildContext context) {
  return Card(
    clipBehavior: Clip.hardEdge,
    margin: const EdgeInsets.all(8.0),
    child: ListTile(
      title: Text(AppLocalizations.of(context)!.about),
      subtitle: Text(AppLocalizations.of(context)!.aboutSub),
      leading: const Icon(Iconsax.info_circle),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutPage()),
        );
      },
    ),
  );
}
