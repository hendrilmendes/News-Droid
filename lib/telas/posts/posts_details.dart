import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newsdroid/models/favorito_model.dart';
import 'package:newsdroid/telas/comentarios/comentarios.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class PostDetailsScreen extends StatefulWidget {
  final String title;
  final String content;
  final String imageUrl;
  final String url;
  final String formattedDate;
  final String blogId;
  final String postId;

  const PostDetailsScreen({
    super.key,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.url,
    required this.formattedDate,
    required this.blogId,
    required this.postId,
  });

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
      _showToast("Removido dos Favoritos");
    } else {
      favoritePostsModel.addFavorite(post);
      _showToast("Adicionado aos Favoritos");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News-Droid"),
      ),

      // Titulo e data publicação do post
      body: ListView(
        padding: const EdgeInsets.all(16.0),
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
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    widget.formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(),
          HtmlWidget(
            widget.content,
            textStyle: TextStyle(fontSize: _fontSize),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),

      // Botão flutuante na parte inferior
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _toggleFavorite(context);
        },
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : null,
        ),
      ),

      // Menu de ações na parte inferior
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: "Diminuir Texto",
              icon: const Icon(Icons.text_decrease_outlined),
              onPressed: _decrementFontSize,
            ),
            IconButton(
              tooltip: "Aumentar Texto",
              icon: const Icon(Icons.text_increase_outlined),
              onPressed: _incrementFontSize,
            ),
            IconButton(
              tooltip: "Compartilhar",
              icon: const Icon(Icons.share_outlined),
              onPressed: () => sharePost(widget.url),
            ),
            IconButton(
              tooltip: "Comentários",
              icon: const Icon(Icons.comment_outlined),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) {
                    return DraggableScrollableSheet(
                      initialChildSize: 0.9,
                      minChildSize: 0.3,
                      maxChildSize: 0.9,
                      expand: false,
                      builder: (_, controller) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: ListView(
                            controller: controller,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.9,
                                width: MediaQuery.of(context).size.width,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  child: CommentScreen(postId: widget.postId),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
