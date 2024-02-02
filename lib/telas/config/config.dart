import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:newsdroid/api/updater.dart';
import 'package:newsdroid/telas/sobre/sobre.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:newsdroid/tema/tema.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String appVersion = '';
  String appBuild = '';
  String authorApp = '';
  String descApp = '';
  bool _notificationsEnabled = true;

  // Metodo para exibir a versao
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
        appBuild = packageInfo.buildNumber;
        authorApp = 'Hendril Mendes';
        descApp =
            'Um projeto amador para um app de notícias que usa a API do Blogger';
      });
    });

    _loadPreferences();

    // Ouvinte de alterações de estado para notificações
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      if (kDebugMode) {
        print('Token atualizado: $token');
      }
    });

    // Ouvinte de notificações
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Mensagem recebida: ${message.data}');
      }

      // Se a notificação contém uma ação, execute-a
      if (message.data['action'] != null) {
        Navigator.pushNamed(context, message.data['action']);
      }
    });
  }

  // Salvar estado das notificacoes
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });

    if (_notificationsEnabled) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && kDebugMode) {
        if (kDebugMode) {
          print('Token registered: $token');
        }
      }
    }
  }

  void _notificationPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', value);

    if (value) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && kDebugMode) {
        if (kDebugMode) {
          print('Token registered: $token');
        }
      }
    } else {
      await FirebaseMessaging.instance.deleteToken();
      if (kDebugMode) {
        print('Token unregistered.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          // Notificacoes
          Card(
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.all(8.0),
            child: SwitchListTile.adaptive(
              activeColor: Colors.blue,
              title: const Text('Notificações'),
              subtitle: const Text(
                "Notificações serão enviadas quando publicarmos novos posts",
              ),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _notificationPreference(value);
              },
            ),
          ),

          // Temas
          Card(
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.all(8.0),
            child: SwitchListTile.adaptive(
              activeColor: Colors.blue,
              title: const Text('Modo Escuro'),
              subtitle: const Text(
                "O modo escuro possibilita uma experiência melhor ao usar o app em ambientes noturnos",
              ),
              value: themeModel.isDarkMode,
              onChanged: (value) {
                themeModel.toggleDarkMode();
                themeModel.saveThemePreference(value);
              },
            ),
          ),

          // Versao
          Card(
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text('Atualizações'),
              subtitle:
                  const Text('Toque para buscar por novas versões do app'),
              onTap: () {
                Updater.checkForUpdates(context);
              },
            ),
          ),
          // Suporte
          Card(
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text(
                'Suporte',
              ),
              subtitle: const Text(
                'Encontrou um bug ou deseja sugerir algo? Entre em contato com a gente 😁',
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    mode: LaunchMode.externalApplication,
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
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                              ),
                              const Text(
                                'Telegram',
                              ),
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
          // Sobre
          Card(
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text('Sobre'),
              subtitle: const Text("Um pouco mais sobre o app"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
