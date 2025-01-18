import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:newsdroid/theme/theme.dart';

class ThemeSettings extends StatelessWidget {
  final ThemeModel themeModel;

  const ThemeSettings({
    super.key,
    required this.themeModel,
  });

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
                return Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            themeModel.changeThemeMode(ThemeModeType.light);
                          });
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Radio(
                              value: ThemeModeType.light,
                              groupValue: themeModel.themeMode,
                              onChanged: (value) {
                                setState(() {
                                  themeModel.changeThemeMode(value!);
                                });
                                Navigator.pop(context);
                              },
                            ),
                            Text(appLocalizations.lightMode),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            themeModel.changeThemeMode(ThemeModeType.dark);
                          });
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Radio(
                              value: ThemeModeType.dark,
                              groupValue: themeModel.themeMode,
                              onChanged: (value) {
                                setState(() {
                                  themeModel.changeThemeMode(value!);
                                });
                                Navigator.pop(context);
                              },
                            ),
                            Text(appLocalizations.darkMode),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            themeModel.changeThemeMode(ThemeModeType.system);
                          });
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Radio(
                              value: ThemeModeType.system,
                              groupValue: themeModel.themeMode,
                              onChanged: (value) {
                                setState(() {
                                  themeModel.changeThemeMode(value!);
                                });
                                Navigator.pop(context);
                              },
                            ),
                            Text(appLocalizations.systemMode),
                          ],
                        ),
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
