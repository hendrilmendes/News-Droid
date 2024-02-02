import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newsdroid/widgets/adaptative_action.dart';
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

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        if (latestVersion.compareTo(currentVersion) > 0) {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (context) => AlertDialog.adaptive(
              title: const Text('Nova Versão Disponível'),
              content: const Text(
                  'Uma nova versão do app está disponível. Deseja Baixar?'),
              actions: <Widget>[
                adaptiveAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('DEPOIS'),
                  context: context,
                ),
                adaptiveAction(
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
                  child: const Text('BAIXAR'),
                  context: context,
                ),
              ],
            ),
          );
        } else {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (context) => AlertDialog.adaptive(
              title: const Text('Nenhuma Atualização Disponível'),
              content: const Text('Tudo em dias parceiro 🤠'),
              actions: <Widget>[
                adaptiveAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                  context: context,
                ),
              ],
            ),
          );
        }
      } else {
        if (kDebugMode) {
          print('Erro ao buscar versão: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ocorreu um erro: $e');
      }
    }
  }
}
