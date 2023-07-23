import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsdroid/tema/tema.dart';
import 'package:newsdroid/telas/licencas/licencas.dart';
import 'package:newsdroid/telas/privacidade/privacidade.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String appVersion = '';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
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

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  void _notificationPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', value);
  }

  void _saveThemePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkModeEnabled', value);
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            CupertinoIcons.back,
          ),
        ),
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: SwitchListTile(
              title: const Text('Notificações'),
              subtitle: const Text(
                "Desative as notificações caso não queira ser notificado com novos posts",
              ),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                  _notificationPreference(value);
                });
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: SwitchListTile(
              title: const Text('Modo Escuro'),
              subtitle: const Text(
                "Habilite modo escuro para uma experiência melhor ao usar o app em ambientes noturnos",
              ),
              value: themeModel.isDarkMode,
              onChanged: (value) {
                themeModel.toggleDarkMode();
                _saveThemePreference(value);
              },
            ),
          ),
          const Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Sobre'),
              subtitle: Text(
                'Um app amador de notícias usando blogger api. Um projeto que surgiu em 2017 mas que existe desde 2015 e aos pouquinhos esta tomando forma, quem sabe de certo né 😆',
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text('Versão'),
              subtitle: Text(appVersion),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text('Licenças'),
              subtitle: const Text("Softwares usados na construção do app"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LicencesPage()),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text('Privacidade'),
              subtitle: const Text("Termos que garantem a sua privacidade"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PolicyPage()),
                );
              },
            ),
          ),
          const Text(
            "Feito com ♥ por Hendril Mendes",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
