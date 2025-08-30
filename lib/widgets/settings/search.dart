import 'package:flutter/material.dart';
import 'package:newsdroid/l10n/app_localizations.dart';
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
    await prefs.setBool('searchBarPosition', value);
    setState(() {
      showSearchBarAtBottom = value;
    });
  }

  void _showPositionDialog(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    bool? selectedPosition = showSearchBarAtBottom;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text(appLocalizations.searchBarPosition),
              // O RadioGroup agora gerencia o estado das opções de rádio
              content: RadioGroup<bool>(
                groupValue: selectedPosition,
                onChanged: (value) {
                  dialogSetState(() {
                    selectedPosition = value;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Os RadioListTiles agora só precisam do 'value'
                    RadioListTile<bool>(
                      title: Text(appLocalizations.positionTop),
                      value: false,
                    ),
                    RadioListTile<bool>(
                      title: Text(appLocalizations.positionBottom),
                      value: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(appLocalizations.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    if (selectedPosition != null) {
                      saveSearchBarPosition(selectedPosition!);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(appLocalizations.ok),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final positionText = showSearchBarAtBottom
        ? AppLocalizations.of(context)!.positionBottom
        : AppLocalizations.of(context)!.positionTop;

    return ListTile(
      title: Text(AppLocalizations.of(context)!.searchPosition),
      subtitle: Text(positionText),
      leading: const Icon(Icons.search_outlined),
      tileColor: Theme.of(context).listTileTheme.tileColor,
      onTap: () {
        _showPositionDialog(context);
      },
    );
  }
}
