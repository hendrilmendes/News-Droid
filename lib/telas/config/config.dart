import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:newsdroid/telas/sobre/sobre.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:newsdroid/tema/tema.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String appVersion = '';
  String appBuild = '';
  bool _notificationsEnabled = true;

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
            margin: const EdgeInsets.all(8.0),
            child: SwitchListTile.adaptive(
              activeColor: Colors.blue,
              title: const Text('Notificações'),
              subtitle: const Text(
                "Desative as notificações caso não queira ser notificado com novos posts",
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
            margin: const EdgeInsets.all(8.0),
            child: SwitchListTile.adaptive(
              activeColor: Colors.blue,
              title: const Text('Modo Escuro'),
              subtitle: const Text(
                "Habilite o modo escuro para uma experiência melhor ao usar o app em ambientes noturnos",
              ),
              value: themeModel.isDarkMode,
              onChanged: (value) {
                themeModel.toggleDarkMode();
                themeModel.saveThemePreference(value);
              },
            ),
          ),
          // Sobre
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text('Sobre'),
              subtitle: const Text("Um pouco mais sobre nozes 🫰🏻"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
          ),
          // Dev
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
