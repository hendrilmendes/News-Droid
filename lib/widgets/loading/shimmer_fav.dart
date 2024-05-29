import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerLoadingFav() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            tileColor: Theme.of(context).listTileTheme.tileColor,
            leading: Container(
              width: 100,
              height: 100,
              color: Colors.white,
            ),
            title: Container(
              width: double.infinity,
              height: 20,
              color: Colors.white,
            ),
            subtitle: Container(
              width: double.infinity,
              height: 16,
              color: Colors.white,
            ),
          ),
        );
      },
    ),
  );
}
