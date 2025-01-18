import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchBarSetting extends StatefulWidget {
  const SearchBarSetting({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchBarSettingState createState() => _SearchBarSettingState();
}

class _SearchBarSettingState extends State<SearchBarSetting> {
  bool showSearchBarAtBottom = true;

  @override
  void initState() {
    super.initState();
    loadSearchBarPosition();
  }

  Future<void> loadSearchBarPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showSearchBarAtBottom = prefs.getBool('searchBarPosition') ?? true;
    });
  }

  Future<void> saveSearchBarPosition(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('searchBarPosition', value);
    setState(() {
      showSearchBarAtBottom = value;
    });
  }

  void _showPositionDialog(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(appLocalizations.searchBarPosition),
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
                            showSearchBarAtBottom = false;
                          });
                        },
                        child: Row(
                          children: [
                            Radio(
                              value: false,
                              groupValue: showSearchBarAtBottom,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  setState(() {
                                    showSearchBarAtBottom = value;
                                  });
                                }
                              },
                            ),
                            Text(appLocalizations.positionTop),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showSearchBarAtBottom = true;
                          });
                        },
                        child: Row(
                          children: [
                            Radio(
                              value: true,
                              groupValue: showSearchBarAtBottom,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  setState(() {
                                    showSearchBarAtBottom = value;
                                  });
                                }
                              },
                            ),
                            Text(appLocalizations.positionBottom),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(appLocalizations.cancel),
              ),
              FilledButton(
                onPressed: () {
                  saveSearchBarPosition(showSearchBarAtBottom);
                  Navigator.of(context).pop();
                },
                child: Text(appLocalizations.ok),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.searchPosition),
      subtitle: Text(AppLocalizations.of(context)!.searchPositionSub),
      leading: const Icon(Icons.search_outlined),
      tileColor: Theme.of(context).listTileTheme.tileColor,
      onTap: () {
        _showPositionDialog(context);
      },
    );
  }
}
