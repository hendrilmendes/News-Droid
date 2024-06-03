import 'package:flutter/material.dart';

Widget buildCategoryHeader(String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: InkWell(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
