import 'package:flutter/material.dart';
import 'package:newsdroid/l10n/app_localizations.dart';
import 'package:newsdroid/theme/theme.dart';

class ThemeSettings extends StatelessWidget {
  final ThemeModel themeModel;

  const ThemeSettings({super.key, required this.themeModel});

  void _showThemeDialog(BuildContext context, ThemeModel themeModel) {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(appLocalizations.themeSelect),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return RadioGroup<ThemeModeType>(
                  groupValue: themeModel.themeMode,
                  onChanged: (ThemeModeType? value) {
                    if (value != null) {
                      setState(() {
                        themeModel.changeThemeMode(value);
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Radio<ThemeModeType>(value: ThemeModeType.light),
                          const SizedBox(width: 8),
                          Text(appLocalizations.lightMode),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<ThemeModeType>(value: ThemeModeType.dark),
                          const SizedBox(width: 8),
                          Text(appLocalizations.darkMode),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<ThemeModeType>(value: ThemeModeType.system),
                          const SizedBox(width: 8),
                          Text(appLocalizations.systemMode),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.theme),
      subtitle: Text(AppLocalizations.of(context)!.themeSub),
      leading: const Icon(Icons.palette_outlined),
      tileColor: Theme.of(context).listTileTheme.tileColor,
      onTap: () {
        _showThemeDialog(context, themeModel);
      },
    );
  }
}
