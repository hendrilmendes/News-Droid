import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final VoidCallback onReload;

  const ErrorScreen({super.key, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/erro/offline.png",
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Sem conexão com a Internet\nVerifique sua conexão e tente novamente.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              FilledButton.tonal(
                  onPressed: onReload, child: const Text("Recarregar")),
            ],
          ),
        ),
      ),
    );
  }
}
