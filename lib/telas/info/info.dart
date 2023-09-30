import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newsdroid/telas/licencas/licencas.dart';
import 'package:newsdroid/telas/privacidade/privacidade.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações Legais'),
      ),
      body: ListView(
        children: [
          // Licencas
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text('Licenças de Código Aberto'),
              subtitle: const Text(
                  "Softwares de terceiros usados na construção do News-Droid"),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => const LicencesPage()),
                );
              },
            ),
          ),

          //Politica de privacidade
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text('Política de Privacidade'),
              subtitle: const Text("Termos que garantem a sua privacidade"),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const PolicyPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
