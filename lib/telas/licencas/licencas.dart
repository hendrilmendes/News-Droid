import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../oss_licenses.dart';

class LicencesPage extends StatelessWidget {
  const LicencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Licenças"),
      ),
      body: Card(
        child: ListView.builder(
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
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => LicenceDetailPage(
                          title: ossLicenses[index].name[0].toUpperCase() +
                              ossLicenses[index].name.substring(1),
                          licence: ossLicenses[index].license!,
                        ),
                      ),
                    );
                  },
                  //capitalize the first letter of the string
                  title: Text(
                    ossLicenses[index].name[0].toUpperCase() +
                        ossLicenses[index].name.substring(1),
                  ),
                  subtitle: Text(ossLicenses[index].description),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

//detail page for the licence
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
      body: Card(
        child: Padding(
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
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
