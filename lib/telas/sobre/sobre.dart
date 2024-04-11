import 'package:flutter/material.dart';
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
    int currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre"),
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
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Copyright © Hendril Mendes, 2015-$currentYear',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Text(
                    "Todos os direitos reservados.",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Um projeto amador para um app de notícias",
                    style: TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  // Versao
                  Card(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Versão"),
                      subtitle: Text('v$appVersion Build: ($appBuild)'),
                      leading: const Icon(Icons.whatshot_outlined),
                      onTap: () {
                        Navigator.pop(context);
                        launchUrl(
                          Uri.parse(
                            'https://raw.githubusercontent.com/hendrilmendes/News-Droid/main/Changelog.md',
                          ),
                          mode: LaunchMode.inAppBrowserView,
                        );
                      },
                    ),
                  ),
                  //Politica de privacidade
                  Card(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Política de Privacidade"),
                      subtitle:
                          const Text("Termos que garantem a sua privacidade"),
                          leading: const Icon(Icons.privacy_tip_outlined),
                      onTap: () {
                        Navigator.pop(context);
                        launchUrl(
                          Uri.parse(
                            'https://br-newsdroid.blogspot.com/p/politica-de-privacidade.html',
                          ),
                          mode: LaunchMode.inAppBrowserView,
                        );
                      },
                    ),
                  ),
                  // Codigo Fonte
                  Card(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Código Fonte"),
                      subtitle: const Text("Projeto disponível no GitHub"),
                      leading: const Icon(Icons.code_outlined),
                      onTap: () {
                        Navigator.pop(context);
                        launchUrl(
                          Uri.parse(
                            'https://github.com/hendrilmendes/News-Droid/',
                          ),
                          mode: LaunchMode.inAppBrowserView,
                        );
                      },
                    ),
                  ),
                  // Licencas
                  Card(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Licenças de Código Aberto"),
                      subtitle: const Text(
                          "Softwares de terceiros usados na construção do app"),
                          leading: const Icon(Icons.flutter_dash_outlined
                        ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LicensePage(
                              applicationName: "News-Droid",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}
