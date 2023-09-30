import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:newsdroid/telas/info/info.dart';
import 'package:newsdroid/api/github_updater.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appVersion = '';
  String appBuild = '';

  // Metodo para exibir a versao
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
        appBuild = packageInfo.buildNumber;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
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
                  const SizedBox(height: 16),
                  const Text(
                    'News-Droid',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                          'Um app simples escrito em flutter que usa API do Blogger para exibir o seu conteúdo.\n\nUm projeto que surgiu em 2017 mas que existe desde 2015 e aos pouquinhos esta tomando forma, quem sabe de certo né 😆'),
                    ),
                  ),

                  // Versao
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text('Versão'),
                      subtitle: Text('v$appVersion Build: ($appBuild)'),
                      onTap: () {
                        GitHubUpdater.checkForUpdates(context);
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text(
                        'Entre em Contato',
                      ),
                      subtitle: const Text(
                        'Encontrou um bug ou deseja sugerir algo? Entre em contato com a gente 😁',
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SizedBox(
                              height: 140,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          MdiIcons.gmail,
                                        ),
                                        iconSize: 40,
                                        tooltip: 'Gmail',
                                        onPressed: () {
                                          Navigator.pop(context);
                                          launchUrl(
                                            Uri.parse(
                                              'mailto:hendrilmendes2015@gmail.com?subject=News-Droid&body=Gostaria%20de%20sugerir%20um%20recurso%20ou%20informar%20um%20bug.',
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      ),
                                      const Text(
                                        'Gmail',
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          MdiIcons.telegram,
                                        ),
                                        iconSize: 40,
                                        tooltip: 'Telegram',
                                        onPressed: () {
                                          Navigator.pop(context);
                                          launchUrl(
                                            Uri.parse(
                                              'https://t.me/hendril_mendes',
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      ),
                                      const Text(
                                        'Telegram',
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          MdiIcons.instagram,
                                        ),
                                        iconSize: 40,
                                        tooltip: 'Instagram',
                                        onPressed: () {
                                          Navigator.pop(context);
                                          launchUrl(
                                            Uri.parse(
                                              'https://instagram.com/hendril_mendes',
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      ),
                                      const Text('Instagram'),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Licencas
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text('Informações Legais'),
                      subtitle: Text(
                          "Copyright © ${DateTime.now().year} Hendril Mendes. Todos os direitos reservados."),
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const InfoScreen()),
                        );
                      },
                    ),
                  ),
                  // Dev
                  const Text(
                    "Feito com ♥ em Flutter",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}
