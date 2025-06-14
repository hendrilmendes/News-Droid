import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newsdroid/auth/auth.dart';
import 'package:newsdroid/l10n/app_localizations.dart';

class AccountUser extends StatelessWidget {
  final User? user;
  final AuthService _authService = AuthService();

  AccountUser({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).listTileTheme.tileColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user!.photoURL ?? ''),
                backgroundColor: Colors.grey.shade200,
              ),
            if (user != null) const SizedBox(width: 20),
            if (user != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user!.displayName ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      user!.email ?? '',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            if (user != null)
              IconButton(
                icon: const Icon(Icons.logout_outlined),
                onPressed: () async {
                  await _authService.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                tooltip: AppLocalizations.of(context)!.desconect,
              ),
          ],
        ),
      ),
    );
  }
}
