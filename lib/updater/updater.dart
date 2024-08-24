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

          showModalBottomSheet(
            // ignore: use_build_context_synchronously
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            isScrollControlled: true,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleText,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations?.news ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      child: SingleChildScrollView(
                        child: Text(releaseNotes),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(localizations?.after ?? ''),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            final Uri uri = Platform.isAndroid
                                ? Uri.parse(
                                    'https://play.google.com/store/apps/details?id=com.github.hendrilmendes.news')
                                : Uri.parse(
                                    'https://github.com/hendrilmendes/News-Droid/releases/latest');

                            launchUrl(uri);
                            Navigator.pop(context); // Fecha o modal
                          },
                          child: Text(localizations?.download ?? ''),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          // ignore: use_build_context_synchronously
          final AppLocalizations? localizations = AppLocalizations.of(context);
          if (localizations != null) {
            showModalBottomSheet(
              // ignore: use_build_context_synchronously
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.noUpdate,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.noUpdateSub,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(localizations.ok),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
