import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newsdroid/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Updater {
  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      final releaseInfo = await _fetchLatestReleaseInfo();
      if (releaseInfo != null) {
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        // Comparação da versão atual com a versão mais recente
        final String latestVersion = releaseInfo['tag_name'];
        if (_isNewerVersion(latestVersion, currentVersion)) {
          // ignore: use_build_context_synchronously
          _showUpdateAvailableModal(context, releaseInfo['body']);
        }
      } else if (kDebugMode) {
        print("Erro ao buscar versão: Nenhuma resposta válida do servidor.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Ocorreu um erro: $e");
      }
      // ignore: use_build_context_synchronously
      _showErrorModal(context);
    }
  }

  // Função para buscar informações da versão mais recente
  static Future<Map<String, dynamic>?> _fetchLatestReleaseInfo() async {
    final response = await http.get(
      Uri.parse(
        'https://api.github.com/repos/hendrilmendes/News-Droid/releases/latest',
      ),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  // Verifica se a nova versão é mais recente que a atual
  static bool _isNewerVersion(String latestVersion, String currentVersion) {
    List<int> latestParts = latestVersion.split('.').map(int.parse).toList();
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
    for (int i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  // Modal para nova atualização disponível
  static void _showUpdateAvailableModal(
    BuildContext context,
    String releaseNotes,
  ) {
    final AppLocalizations? localizations = AppLocalizations.of(context);
    final String titleText = localizations?.newUpdate ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titleText),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              maxWidth: 400,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations?.news ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(releaseNotes),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations?.after ?? ''),
            ),
            FilledButton(
              onPressed: () {
                final Uri uri = Platform.isAndroid
                    ? Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.github.hendrilmendes.news',
                      )
                    : Uri.parse(
                        'https://github.com/hendrilmendes/News-Droid/releases/latest',
                      );
                launchUrl(uri);
                Navigator.pop(context);
              },
              child: Text(localizations?.download ?? ''),
            ),
          ],
        );
      },
    );
  }

  static Future<void> checkUpdateApp(BuildContext context) async {
    try {
      final releaseInfo = await _fetchLatestReleaseInfo();
      if (releaseInfo != null) {
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        // Comparação da versão atual com a versão mais recente
        final String latestVersion = releaseInfo['tag_name'];
        if (_isNewerVersion(latestVersion, currentVersion)) {
          // ignore: use_build_context_synchronously
          _showUpdateAvailableModal(context, releaseInfo['body']);
        }
      } else if (kDebugMode) {
        print("Erro ao buscar versão: Nenhuma resposta válida do servidor.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Ocorreu um erro: $e");
      }
      // ignore: use_build_context_synchronously
      _showErrorModal(context);
    }
  }

  // Modal para erros de atualização
  static void _showErrorModal(BuildContext context) {
    final AppLocalizations? localizations = AppLocalizations.of(context);
    if (localizations != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(localizations.error),
            content: Text(localizations.errorUpdate),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.ok),
              ),
            ],
          );
        },
      );
    }
  }
}
