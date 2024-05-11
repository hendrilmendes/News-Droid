import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Updater {
  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.github.com/repos/hendrilmendes/News-Droid/releases/latest'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> releaseInfo = json.decode(response.body);

        final String latestVersion = releaseInfo['tag_name'];
        final String releaseNotes = releaseInfo['body'];

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        if (latestVersion.compareTo(currentVersion) > 0) {
          // ignore: use_build_context_synchronously
          final AppLocalizations? localizations = AppLocalizations.of(context);
          final String titleText = localizations?.newUpdate ?? '';
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => AlertDialog(
              title: Text(titleText),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizations?.news ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        releaseNotes,
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localizations?.after ?? ''),
                ),
                FilledButton(
                  onPressed: () {
                    if (Platform.isAndroid) {
                      // Android
                      launchUrl(
                        Uri.parse(
                            'https://play.google.com/store/apps/details?id=com.github.hendrilmendes.news'),
                      );
                      Navigator.pop(context); // Fecha o diálogo interno
                    } else {
                      // iOS
                      launchUrl(
                        Uri.parse(
                            'https://github.com/hendrilmendes/News-Droid/releases/latest'),
                      );
                      Navigator.pop(context); // Fecha o diálogo interno
                    }
                  },
                  child: Text(localizations?.download ?? ''),
                ),
              ],
            ),
          );
        } else {
          // ignore: use_build_context_synchronously
          final AppLocalizations? localizations = AppLocalizations.of(context);
          if (localizations != null) {
            showDialog(
              // ignore: use_build_context_synchronously
              context: context,
              builder: (context) => AlertDialog(
                title: Text(localizations.noUpdate),
                content: Text(
                  localizations.noUpdateSub,
                  style: const TextStyle(fontSize: 16.0),
                ),
                actions: <Widget>[
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(localizations.ok),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        if (kDebugMode) {
          print("Erro ao buscar versão: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Ocorreu um erro: $e");
      }
    }
  }
}
