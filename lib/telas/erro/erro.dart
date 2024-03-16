import 'package:flutter/material.dart';

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
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Text(
                    "Sem conexão com a Internet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Verifique sua conexão e tente novamente.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                  ),
                  FilledButton.tonal(
                    onPressed: onReload,
                    child: const Text("Recarregar"),
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
