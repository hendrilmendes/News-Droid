import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
  final Directory output = await getTemporaryDirectory();
  final String screenshotFilePath = '${output.path}/feedback.png';
  final File screenshotFile = File(screenshotFilePath);
  await screenshotFile.writeAsBytes(feedbackScreenshot);
  return screenshotFilePath;
}

Widget buildSupportSettings(BuildContext context) {
  return Card(
    clipBehavior: Clip.hardEdge,
    margin: const EdgeInsets.all(8.0),
    child: ListTile(
      title: Text(AppLocalizations.of(context)!.support),
      subtitle: Text(AppLocalizations.of(context)!.supportSub),
      leading: const Icon(Icons.support_outlined),
      onTap: () {
        BetterFeedback.of(context).show((feedback) async {
          final screenshotFilePath =
              await writeImageToStorage(feedback.screenshot);

          final Email email = Email(
            body: feedback.text,
            // ignore: use_build_context_synchronously
            subject: AppLocalizations.of(context)!.appName,
            recipients: ['hendrilmendes2015@gmail.com'],
            attachmentPaths: [screenshotFilePath],
            isHTML: false,
          );
          await FlutterEmailSender.send(email);
        });
      },
    ),
  );
}
