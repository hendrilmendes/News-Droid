import 'package:flutter/material.dart';
import 'package:newsdroid/oss_licenses.dart';

class LicencesPage extends StatelessWidget {
  const LicencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Licenças de Código Aberto"),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: ossLicenses.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LicenceDetailPage(
                          title: ossLicenses[index].name[0].toUpperCase() +
                              ossLicenses[index].name.substring(1),
                          licence: ossLicenses[index].license!,
                        ),
                      ),
                    );
                  },
                  title: Text(
                    ossLicenses[index].name[0].toUpperCase() +
                        ossLicenses[index].name.substring(1),
                  ),
                  subtitle: Text(ossLicenses[index].description),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Detalhes da Licenca
class LicenceDetailPage extends StatelessWidget {
  final String title, licence;
  const LicenceDetailPage(
      {super.key, required this.title, required this.licence});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10)),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Text(
                  licence,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
