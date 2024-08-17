// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget buildReviewSettings(BuildContext context) {
  return Card(
    clipBehavior: Clip.hardEdge,
    margin: const EdgeInsets.all(8.0),
    child: ListTile(
      title: Text(AppLocalizations.of(context)!.review),
      subtitle: Text(AppLocalizations.of(context)!.reviewSub),
      leading: const Icon(Icons.reviews_outlined),
      onTap: () async {
        final InAppReview inAppReview = InAppReview.instance;

        if (await inAppReview.isAvailable()) {
          final hasReviewed = await checkReviewed();
          if (hasReviewed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.alreadyReviewed),
            ));
          } else {
            inAppReview.requestReview();
            await markReviewed();
          }
        }
      },
    ),
  );
}

Future<bool> checkReviewed() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasReviewed') ?? false;
}

Future<void> markReviewed() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('hasReviewed', true);
}
