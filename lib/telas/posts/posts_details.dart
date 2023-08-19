import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class PostDetailsScreen extends StatefulWidget {
  final String title;
  final String content;
  final String imageUrl;
  final String url;
  final String formattedDate;

  const PostDetailsScreen({
    Key? key,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.url,
    required this.formattedDate,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  double _fontSize = 18.0;

  // Metodo para compatilhar os posts
  void sharePost(String shared) {
    Share.share(widget.url);
  }

  // Metodo para aumentar e diminuir tamanho do texto nos posts
  void _decrementFontSize() {
    setState(() {
      _fontSize = _fontSize - 2.0;
    });
  }

  void _incrementFontSize() {
    setState(() {
      _fontSize = _fontSize + 2.0;
    });
  }

  // Icon de Compartilhamento
  // ignore: non_constant_identifier_names
  Icon _SharedIcon() {
    if (Platform.isAndroid) {
      return const Icon(Icons.share_outlined);
    } else {
      return const Icon(CupertinoIcons.share_solid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News-Droid'),

        // Actions para aumentar e diminuir tamanho do texto nos posts
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease_outlined),
            onPressed: _decrementFontSize,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase_outlined),
            onPressed: _incrementFontSize,
          ),
        ],
      ),

      // Titulo e data publicação do post
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Publicado em ${widget.formattedDate}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Widget que recebe os conteúdos do blogger
            HtmlWidget(widget.content,
                textStyle: TextStyle(fontSize: _fontSize)),
          ],
        ),
      ),

      //Floating Action de Compartilhamento
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.blue,
        child: Center(
          child: _SharedIcon(),
        ),
        onPressed: () => sharePost(widget.url),
      ),
    );
  }
}
