import 'dart:io';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:newsdroid/updater/updater.dart';
import 'package:newsdroid/telas/sobre/sobre.dart';
import 'package:path_provider/path_provider.dart';
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
  bool _notificationsEnabled = true;

  // Metodo para exibir a versao
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

  Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
    final Directory output = await getTemporaryDirectory();
    final String screenshotFilePath = '${output.path}/feedback.png';
    final File screenshotFile = File(screenshotFilePath);
    await screenshotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          _buildCategoryHeader(AppLocalizations.of(context)!.notification,
              Icons.notifications_outlined),
          _buildNotificationSettings(),
          _buildCategoryHeader(
              AppLocalizations.of(context)!.interface, Icons.palette_outlined),
          _buildThemeSettings(context, themeModel),
          _buildCategoryHeader(
              AppLocalizations.of(context)!.outhers, Icons.more_horiz_outlined),
          _buildUpdateSettings(),
          _buildReview(),
          _buildSupportSettings(),
          _buildAboutSettings(),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8.0),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(AppLocalizations.of(context)!.notification),
        subtitle: Text(
          AppLocalizations.of(context)!.notificationSub,
        ),
        trailing: Switch(
          activeColor: Colors.blue,
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            _notificationPreference(value);
          },
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeModel themeModel) {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(appLocalizations.themeSelect),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            themeModel.changeThemeMode(ThemeModeType.light);
                          });
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Radio(
                              activeColor: Colors.blue,
                              value: ThemeModeType.light,
                              groupValue: themeModel.themeMode,
                              onChanged: (value) {
                                setState(() {
                                  themeModel.changeThemeMode(value!);
                                });
                                Navigator.pop(context);
                              },
                            ),
                            Text(appLocalizations.lightMode),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            themeModel.changeThemeMode(ThemeModeType.dark);
                          });
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Radio(
                              activeColor: Colors.blue,
                              value: ThemeModeType.dark,
                              groupValue: themeModel.themeMode,
                              onChanged: (value) {
                                setState(() {
                                  themeModel.changeThemeMode(value!);
                                });
                                Navigator.pop(context);
                              },
                            ),
                            Text(appLocalizations.darkMode),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            themeModel.changeThemeMode(ThemeModeType.system);
                          });
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Radio(
                              activeColor: Colors.blue,
                              value: ThemeModeType.system,
                              groupValue: themeModel.themeMode,
                              onChanged: (value) {
                                setState(() {
                                  themeModel.changeThemeMode(value!);
                                });
                                Navigator.pop(context);
                              },
                            ),
                            Text(appLocalizations.systemMode),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }

  Widget _buildThemeSettings(BuildContext context, ThemeModel themeModel) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(AppLocalizations.of(context)!.theme),
        subtitle: Text(AppLocalizations.of(context)!.themeSub),
        onTap: () {
          _showThemeDialog(context, themeModel);
        },
      ),
    );
  }

  Widget _buildUpdateSettings() {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(AppLocalizations.of(context)!.update),
        subtitle: Text(AppLocalizations.of(context)!.updateSub),
        leading: const Icon(Icons.update_outlined),
        onTap: () {
          Updater.checkForUpdates(context);
        },
      ),
    );
  }

  Widget _buildSupportSettings() {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          AppLocalizations.of(context)!.support,
        ),
        subtitle: Text(
          AppLocalizations.of(context)!.supportSub,
        ),
        leading: const Icon(Icons.support_outlined),
        onTap: () {
          BetterFeedback.of(context).show((feedback) async {
            final screenshotFilePath =
                await writeImageToStorage(feedback.screenshot);

            final Email email = Email(
              body: feedback.text,
              // ignore: use_build_context_synchronously
              subject: AppLocalizations.of(context)!.appName,
              recipients: ['hendrilmendes2015@gmail.com'],
              attachmentPaths: [screenshotFilePath],
              isHTML: false,
            );
            await FlutterEmailSender.send(email);
          });
        },
      ),
    );
  }

  Widget _buildReview() {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(AppLocalizations.of(context)!.review),
        subtitle: Text(AppLocalizations.of(context)!.reviewSub),
        leading: const Icon(Icons.rate_review_outlined),
        onTap: () async {
          final InAppReview inAppReview = InAppReview.instance;

          if (await inAppReview.isAvailable()) {
            inAppReview.requestReview();
          }
        },
      ),
    );
  }

  Widget _buildAboutSettings() {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          AppLocalizations.of(context)!.about,
        ),
        subtitle: Text(AppLocalizations.of(context)!.aboutSub),
        leading: const Icon(Icons.info_outlined),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutPage()),
          );
        },
      ),
    );
  }
}
