// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
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

    final favoritePostsModel = Provider.of<FavoritePostsModel>(
      context,
      listen: false,
    );
    _isFavorite = favoritePostsModel.favoritePosts.any(
      (post) => post.postId == widget.postId,
    );
  }

  void _initializeTts() async {
    flutterTts.setStartHandler(() {});
    flutterTts.setCompletionHandler(() {});
    flutterTts.setErrorHandler((msg) {
      _showToast("Erro ao ler o texto: $msg");
    });

    var isLanguageAvailable = await flutterTts.isLanguageAvailable("pt-BR");
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

  void _readTextAloud() async {
    var document = html_parser.parse(widget.content);
    var text = document.body?.text ?? widget.content;
    await flutterTts.speak(text);
  }

  void sharePost(String shared) {
    SharePlus.instance.share(ShareParams(text: widget.url));
  }

  void _decrementFontSize() {
    setState(() {
      _fontSize = (_fontSize - 2.0).clamp(12.0, 28.0);
    });
  }

  void _incrementFontSize() {
    setState(() {
      _fontSize = (_fontSize + 2.0).clamp(12.0, 28.0);
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
      _isFavorite = !_isFavorite;
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: isDark ? Colors.black : Colors.white,
                expandedHeight: size.height * (size.width < 600 ? 0.32 : 0.24),
                floating: false,
                pinned: true,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                actions: [
                  IconButton(
                    icon: Icon(Icons.mic_none_rounded),
                    onPressed: _readTextAloud,
                    tooltip: AppLocalizations.of(context)!.readLoud,
                  ),
                ],
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final double top = constraints.biggest.height;
                    final bool isCollapsed =
                        top <=
                        kToolbarHeight +
                            MediaQuery.of(context).padding.top +
                            10;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        if (!isCollapsed)
                          Hero(
                            tag: widget.imageUrl,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(28),
                                bottomRight: Radius.circular(28),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: widget.imageUrl,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(color: Colors.white),
                                    ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    color: Colors.grey[400],
                                    size: 56,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (!isCollapsed)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(28),
                                bottomRight: Radius.circular(28),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        if (!isCollapsed)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surface.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Text(
                                    widget.title,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: size.width < 600 ? 22 : 28,
                                          letterSpacing: -0.5,
                                        ),
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (isCollapsed)
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 72,
                              vertical: 12,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                widget.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  letterSpacing: -0.5,
                                  overflow: TextOverflow.visible,
                                ),
                                maxLines: null,
                                softWrap: false,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.formattedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AdBanner(),
                          const SizedBox(height: 20),
                          HtmlWidget(
                            widget.content,
                            textStyle: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: _fontSize,
                              height: 1.6,
                              color: isDark
                                  ? Colors.grey[100]
                                  : Colors.grey[900],
                            ),
                            enableCaching: true,
                          ),
                          const SizedBox(height: 20),
                          AdBanner(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        backgroundColor: isDark ? Colors.white10 : Colors.white,
        onPressed: () => _toggleFavorite(context),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
          color: _isFavorite ? Colors.red : theme.colorScheme.primary,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: SafeArea(
          top: false,
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
                    backgroundColor: Colors.transparent,
                    builder: (_) {
                      return DraggableScrollableSheet(
                        initialChildSize: 0.9,
                        minChildSize: 0.3,
                        maxChildSize: 0.9,
                        expand: false,
                        builder: (_, controller) {
                          return Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[900] : Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: ListView(
                              controller: controller,
                              children: [
                                SizedBox(
                                  height: size.height * 0.9,
                                  width: size.width,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                      topRight: Radius.circular(24),
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
