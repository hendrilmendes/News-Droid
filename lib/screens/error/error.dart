import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorScreen extends StatelessWidget {
  final VoidCallback onReload;

  const ErrorScreen({super.key, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Image.asset(
                  'assets/erro/offline.png',
                  width: MediaQuery.of(context).size.width * 1.0,
                  height: MediaQuery.of(context).size.width * 1.0,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.noConnection,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      AppLocalizations.of(context)!.noConnectionSub,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                  ),
                  FilledButton(
                    onPressed: onReload,
                    child: Text(AppLocalizations.of(context)!.refresh),
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
