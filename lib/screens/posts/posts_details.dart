import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:newsdroid/l10n/app_localizations.dart';
import 'package:newsdroid/models/favorite_model.dart';
import 'package:newsdroid/screens/comments/comments.dart';
import 'package:newsdroid/widgets/ads/ads.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart' as html_parser;

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
  double _fontSize = 16;
  bool _isFavorite = false;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initializeTts();

    // Verificar se o post atual já está nos favoritos ao entrar na tela
    final favoritePostsModel = Provider.of<FavoritePostsModel>(
      context,
      listen: false,
    );
    _isFavorite = favoritePostsModel.favoritePosts.any(
      (post) => post.postId == widget.postId,
    );
  }

  void _initializeTts() async {
    // Configurar handlers
    flutterTts.setStartHandler(() {
      if (kDebugMode) {
        print("Iniciando a leitura do texto...");
      }
    });

    flutterTts.setCompletionHandler(() {
      if (kDebugMode) {
        print("Leitura do texto completada");
      }
    });

    flutterTts.setErrorHandler((msg) {
      if (kDebugMode) {
        print("Erro ao ler o texto: $msg");
      }
      _showToast("Erro ao ler o texto: $msg");
    });

    var languages = await flutterTts.getLanguages;
    if (kDebugMode) {
      print("Idiomas disponíveis: $languages");
    }

    var isLanguageAvailable = await flutterTts.isLanguageAvailable("pt-BR");
    if (kDebugMode) {
      print("Idioma pt-BR está disponível: $isLanguageAvailable");
    }

    if (isLanguageAvailable) {
      await flutterTts.setLanguage("pt-BR");
    }

    await flutterTts.setSpeechRate(0.6);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  // Metodo para ler o texto em voz alta
  void _readTextAloud() async {
    if (kDebugMode) {
      print("Tentando ler o texto em voz alta");
    }
    var document = html_parser.parse(widget.content);
    var text = document.body?.text ?? widget.content;
    var result = await flutterTts.speak(text);
    if (result == 1) {
      if (kDebugMode) {
        print("Texto lido com sucesso");
      }
    } else {
      if (kDebugMode) {
        print("Falha ao ler o texto: $result");
      }
      _showToast("Falha ao ler o texto: $result");
    }
  }

  // Metodo para compartilhar os posts
  void sharePost(String shared) {
    SharePlus.instance.share(ShareParams(text: widget.url));
  }

  // Metodo para aumentar e diminuir tamanho do texto nos posts
  void _decrementFontSize() {
    setState(() {
      _fontSize -= 2.0;
    });
  }

  void _incrementFontSize() {
    setState(() {
      _fontSize += 2.0;
    });
  }

  void _toggleFavorite(BuildContext context) {
    final favoritePostsModel = Provider.of<FavoritePostsModel>(
      context,
      listen: false,
    );

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
    } else {
      favoritePostsModel.addFavorite(post);
    }

    setState(() {
      _isFavorite = !_isFavorite; // Alternar o estado do post favorito
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.mic_none_outlined),
                onPressed: _readTextAloud,
                tooltip: AppLocalizations.of(context)!.readLoud,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder(
                    future: precacheImage(
                      NetworkImage(widget.imageUrl),
                      context,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                            child: Container(color: Colors.white),
                          ),
                        );
                      }
                    },
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(150, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.formattedDate,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Column(children: [AdBanner()]),
                const SizedBox(height: 16),
                HtmlWidget(
                  widget.content,
                  textStyle: TextStyle(fontSize: _fontSize),
                  enableCaching: true,
                ),
                const SizedBox(height: 16),
              ]),
            ),
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
          _isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
          color: _isFavorite ? Colors.red : null,
        ),
      ),

      // Menu de ações na parte inferior
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: AppLocalizations.of(context)!.decrementText,
                icon: const Icon(Icons.text_decrease_outlined),
                onPressed: _decrementFontSize,
              ),
              IconButton(
                tooltip: AppLocalizations.of(context)!.incrementText,
                icon: const Icon(Icons.text_increase_outlined),
                onPressed: _incrementFontSize,
              ),
              IconButton(
                tooltip: AppLocalizations.of(context)!.shared,
                icon: const Icon(Icons.share_outlined),
                onPressed: () => sharePost(widget.url),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context)!.comments,
                icon: const Icon(Icons.insert_comment_outlined),
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
      ),
    );
  }
}
