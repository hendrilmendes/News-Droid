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
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Sem conexão com a Internet. Verifique sua conexão e tente novamente.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              ElevatedButton.icon(
                  onPressed: onReload,
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text("Recarregar"))
            ],
          ),
        ),
      ),
    );
  }
}
