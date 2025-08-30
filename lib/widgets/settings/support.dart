import 'package:flutter/material.dart';
import 'package:newsdroid/l10n/app_localizations.dart';
import 'package:wiredash/wiredash.dart';

Widget buildSupportSettings(BuildContext context) {
  return ListTile(
    title: Text(AppLocalizations.of(context)!.support),
    subtitle: Text(AppLocalizations.of(context)!.supportSub),
    leading: const Icon(Icons.support_outlined),
    tileColor: Theme.of(context).listTileTheme.tileColor,
    onTap: () {
      Wiredash.of(context).show(inheritMaterialTheme: true);
    },
  );
}
