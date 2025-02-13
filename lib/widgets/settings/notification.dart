import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:newsdroid/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();

    // Ouvinte de alterações de estado para notificações
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      if (kDebugMode) {
        print("Token atualizado: $token");
      }
    });

    // Ouvinte de notificações
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Mensagem recebida: ${message.data}");
      }

      // Se a notificação contém uma ação, execute
      if (message.data['action'] != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, message.data['action']);
      }
    });
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });

    if (_notificationsEnabled) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && kDebugMode) {
        if (kDebugMode) {
          print("Token registrado: $token");
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
          print("Token registrado: $token");
        }
      }
    } else {
      await FirebaseMessaging.instance.deleteToken();
      if (kDebugMode) {
        print("Token não registrado.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.notification),
      subtitle: Text(AppLocalizations.of(context)!.notificationSub),
      tileColor: Theme.of(context).listTileTheme.tileColor,
      trailing: Switch(
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() {
            _notificationsEnabled = value;
          });
          _notificationPreference(value);
        },
      ),
    );
  }
}
