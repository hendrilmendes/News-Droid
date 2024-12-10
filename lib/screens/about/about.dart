import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appVersion = '';
  String appBuild = '';
  String releaseNotes = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
        appBuild = packageInfo.buildNumber;
      });

      // Buscar as informações de release do GitHub após obter a versão
      _fetchReleaseInfo();
    });
  }

  Future<void> _fetchReleaseInfo() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.github.com/repos/hendrilmendes/News-Droid/releases'));

      if (response.statusCode == 200) {
        final List<dynamic> releases = jsonDecode(response.body);

        String versionRelease = '';

        for (var release in releases) {
          if (release['tag_name'] == appVersion) {
            versionRelease = release['body'];
            break;
          }
        }

        setState(() {
          releaseNotes = versionRelease.isNotEmpty
              ? versionRelease
              : 'Release para esta versão não encontrada. Verifique se há uma versão correspondente no GitHub.';
          isLoading = false;
        });
      } else {
        setState(() {
          releaseNotes =
              'Erro ao carregar as releases. Código: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        releaseNotes =
            'Erro ao carregar as releases. Verifique a conexão com a internet ou o formato das releases no GitHub.';
        isLoading = false;
      });
    }
  }

  void _showReleaseInfo(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${AppLocalizations.of(context)!.version} - v$appVersion'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: isLoading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator.adaptive(),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        releaseNotes,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.about,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Card(
              elevation: 15,
              shape: CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 80,
                child: Image(
                  image: AssetImage('assets/img/ic_launcher.png'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Copyright © Hendril Mendes, 2015-$currentYear',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.copyright,
              style: const TextStyle(fontSize: 12),
            ),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.appDesc,
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 10),
            const Divider(),
            Card(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.version),
                    subtitle: Text('v$appVersion Build: ($appBuild)'),
                    leading: const Icon(Icons.whatshot_outlined),
                    tileColor: Theme.of(context).listTileTheme.tileColor,
                    onTap: () => _showReleaseInfo(context),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.privacy),
                    subtitle: Text(AppLocalizations.of(context)!.privacySub),
                    leading: const Icon(Icons.shield_outlined),
                    tileColor: Theme.of(context).listTileTheme.tileColor,
                    onTap: () {
                      launchUrl(
                        Uri.parse(
                          'https://br-newsdroid.blogspot.com/p/politica-de-privacidade.html',
                        ),
                        mode: LaunchMode.inAppBrowserView,
                      );
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.sourceCode),
                    subtitle: Text(AppLocalizations.of(context)!.sourceCodeSub),
                    leading: const Icon(Icons.code_outlined),
                    tileColor: Theme.of(context).listTileTheme.tileColor,
                    onTap: () {
                      launchUrl(
                        Uri.parse(
                            'https://github.com/hendrilmendes/News-Droid/'),
                        mode: LaunchMode.inAppBrowserView,
                      );
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.openSource),
                    subtitle: Text(AppLocalizations.of(context)!.openSourceSub),
                    leading: const Icon(Icons.folder_open),
                    tileColor: Theme.of(context).listTileTheme.tileColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LicensePage(
                            applicationName:
                                AppLocalizations.of(context)!.appName,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
