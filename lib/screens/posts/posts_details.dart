import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:newsdroid/models/favorite_model.dart';
import 'package:newsdroid/screens/comments/comments.dart';
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
      _showToast(AppLocalizations.of(context)!.removedFavorite);
    } else {
      favoritePostsModel.addFavorite(post);
      _showToast(AppLocalizations.of(context)!.addFavorite);
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
        title: Text(AppLocalizations.of(context)!.appName),
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
                  const Icon(Iconsax.calendar, size: 12, color: Colors.grey),
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
          _isFavorite ? Iconsax.heart5 : Iconsax.heart,
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
              tooltip: AppLocalizations.of(context)!.decrementText,
              icon: const Icon(Iconsax.arrow_down_2),
              onPressed: _decrementFontSize,
            ),
            IconButton(
              tooltip: AppLocalizations.of(context)!.incrementText,
              icon: const Icon(Iconsax.arrow_up_1),
              onPressed: _incrementFontSize,
            ),
            IconButton(
              tooltip: AppLocalizations.of(context)!.shared,
              icon: const Icon(Iconsax.share),
              onPressed: () => sharePost(widget.url),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context)!.comments,
              icon: const Icon(Iconsax.message),
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
