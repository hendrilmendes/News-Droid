  import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerLoadingSearch() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisExtent: 300.0,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.all(10.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.white),
          ),
        );
      },
    );
  }
