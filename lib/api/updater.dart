import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Nova Versão Disponível"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "A versão $latestVersion do News-Droid está disponível. Você esta usando a versão $currentVersion.",
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Novidades:",
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                  child: const Text("DEPOIS"),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    if (Platform.isAndroid) {
                      // Android
                      launchUrl(Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.github.hendrilmendes.news'));
                      Navigator.pop(context); // Fecha o diálogo interno
                    } else {
                      // iOS
                      launchUrl(Uri.parse(
                          'https://github.com/hendrilmendes/News-Droid/releases/latest'));
                      Navigator.pop(context); // Fecha o diálogo interno
                    }
                  },
                  child: const Text("BAIXAR"),
                ),
              ],
            ),
          );
        } else {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Nenhuma Atualização Disponível"),
              content: const Text("Tudo em dias parceiro 🤠"),
              actions: <Widget>[
                FilledButton.tonal(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
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
