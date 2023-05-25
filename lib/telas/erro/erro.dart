import 'package:flutter/material.dart';

import '../../componentes/voltar.dart';

class ErrorScreen extends StatelessWidget {
  ErrorScreen({
    super.key,
    required this.isOffline,
    required this.onPressed,
  });

  final bool isOffline;
  final VoidCallback onPressed;
  final BackPressed _backPressed = BackPressed();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _backPressed.exit(context),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  isOffline == true
                      ? "assets/erro/offline.png"
                      : "assets/erro/erro.png",
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.width * 0.6,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    isOffline == true
                        ? "Sem conexão com a Internet. Verifique sua conexão e tente novamente."
                        : "Ocorreu um erro desconhecido. Por favor, tente novamente mais tarde",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                ElevatedButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Recarregar"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
