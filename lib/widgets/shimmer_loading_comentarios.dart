import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerLoadingComments() {
  return ListView.builder(
    itemCount: 5,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: ListTile(
              tileColor: Theme.of(context).cardColor,
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 200,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 4),
                  ),
                  Container(
                    height: 16,
                    width: 140,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 4),
                  ),
                  Container(
                    height: 16,
                    width: 80,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
