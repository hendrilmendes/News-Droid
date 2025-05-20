import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:newsdroid/auth/auth.dart';
import 'package:newsdroid/l10n/app_localizations.dart';
import 'package:newsdroid/widgets/bottom_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  final AuthService authService;

  const LoginScreen({required this.authService, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const Card(
              elevation: 15,
              shape: CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
              width: 140,
              child: Image(image: AssetImage('assets/img/ic_launcher.png')),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.appName,
              style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[100]
                : Colors.grey[900],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
              AppLocalizations.of(context)!.homeLogin,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[100]
                  : Colors.grey[900],
              ),
              textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: () async {
              final user = await authService.signInWithGoogle();
              if (user != null) {
                Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(
                  builder: (context) => const BottomNavigationContainer(),
                ),
                );
                if (kDebugMode) {
                print('Usuário autenticado: ${user.displayName}');
                }
              } else {
                // Tratar falha na autenticação
                if (kDebugMode) {
                print('Falha na autenticação');
                }
              }
              },

              style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.grey[100],
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[100]
                : Colors.grey[900],
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              ),
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                'assets/img/google_logo.png',
                width: 20,
                height: 20,
                ),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.googleLogin),
              ],
              ),
            ),
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text.rich(
              TextSpan(
                children: [
                TextSpan(
                  text: "Ao continuar, você concorda com a nossa ",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                TextSpan(
                  text: "Política de Privacidade",
                  style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[100]
                    : Colors.grey[900],
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    const url = 'https://br-newsdroid.blogspot.com/p/politica-de-privacidade.html';
                    if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
                    }
                  },
                ),
                ],
              ),
              textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
