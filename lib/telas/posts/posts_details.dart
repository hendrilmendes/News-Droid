import 'dart:io';
import 'package:animated_floating_buttons/widgets/animated_floating_action_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newsdroid/models/favorito_model.dart';
import 'package:newsdroid/telas/comentarios/comentarios.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

final GlobalKey<AnimatedFloatingActionButtonState> key =
    GlobalKey<AnimatedFloatingActionButtonState>();

class PostDetailsScreen extends StatefulWidget {
  final String title;
  final String content;
  final String imageUrl;
  final String url;
  final String formattedDate;
  final String blogId;
  final String postId;

  const PostDetailsScreen({
    Key? key,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.url,
    required this.formattedDate,
    required this.blogId,
    required this.postId,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  double _fontSize = 18.0;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    // Verificar se o post atual já está nos favoritos ao entrar na tela
    final favoritePostsModel =
        Provider.of<FavoritePostsModel>(context, listen: false);
    _isFavorite = favoritePostsModel.favoritePosts
        .any((post) => post.postId == widget.postId);
  }

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

  void _toggleFavorite(BuildContext context) {
    final favoritePostsModel =
        Provider.of<FavoritePostsModel>(context, listen: false);

    final post = FavoritePost(
      postId: widget.postId,
      title: widget.title,
      content: widget.content,
      imageUrl: widget.imageUrl,
      url: widget.url,
      formattedDate: widget.formattedDate,
      blogId: widget.blogId,
    );

    if (_isFavorite) {
      favoritePostsModel.removeFavorite(widget.postId);
      _showToast('Removido dos Favoritos');
    } else {
      favoritePostsModel.addFavorite(post);
      _showToast('Salvo em Favoritos');
    }

    setState(() {
      _isFavorite = !_isFavorite; // Alternar o estado do post favorito
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
    );
  }

  // Icon de Compartilhamento
  // ignore: non_constant_identifier_names
  Icon _SharedIcon() {
    if (Platform.isAndroid) {
      return const Icon(Icons.share_outlined);
    } else {
      return const Icon(CupertinoIcons.share);
    }
  }

  // ignore: non_constant_identifier_names
  Icon _CommentIcon() {
    if (Platform.isAndroid) {
      return const Icon(Icons.comment_outlined);
    } else {
      return const Icon(CupertinoIcons.text_bubble);
    }
  }

  Widget float1() {
    return FloatingActionButton(
      onPressed: () => sharePost(widget.url),
      heroTag: "btn1",
      tooltip: 'Compartilhar',
      child: _SharedIcon(),
    );
  }

  Widget float2(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: CommentScreen(
                postId: widget.postId,
              ),
            );
          },
        );
      },
      heroTag: "btn2",
      tooltip: 'Comentar',
      child: _CommentIcon(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News-Droid'),

        // Actions para aumentar e diminuir tamanho do texto nos posts
        actions: [
          IconButton(
            color: Colors.blue,
            icon: const Icon(Icons.text_decrease_outlined),
            onPressed: _decrementFontSize,
          ),
          IconButton(
            color: Colors.blue,
            icon: const Icon(Icons.text_increase_outlined),
            onPressed: _incrementFontSize,
          ),
          IconButton(
            color: Colors.blue,
            icon: _isFavorite
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_border),
            onPressed: () {
              _toggleFavorite(context);
            },
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
      floatingActionButton: AnimatedFloatingActionButton(
          fabButtons: <Widget>[float1(), float2(context)],
          key: key,
          tooltip: 'Mais',
          colorStartAnimation: Colors.blue,
          colorEndAnimation: Colors.blue,
          animatedIconData: AnimatedIcons.menu_close),
    );
  }
}
