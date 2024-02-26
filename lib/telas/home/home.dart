import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:newsdroid/widgets/progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:newsdroid/telas/erro/erro.dart';
import 'package:newsdroid/telas/posts/posts_details.dart';
import 'package:newsdroid/api/api.dart';
import 'package:newsdroid/tema/tema.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> posts = [];
  List<dynamic> filteredPosts = [];
  List<dynamic> favoritePosts = [];

  bool isDarkMode = false;
  int currentIndex = 0;
  bool isOnline = true;
  bool isLoading = false;

  // Defina uma variável para armazenar o postId da postagem atual
  String? postId;

  @override
  void initState() {
    super.initState();
    fetchPosts();
    checkConnectivity();
  }

  // GET API
  Future<void> fetchPosts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      final response = await http.get(Uri.parse(
          'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts?key=$apiKey'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          posts = data['items'];
          filteredPosts = posts;
          isLoading = false;
        });
      } else {
        throw Exception("Falha ao buscar postagens");
      }
    } catch (e) {
      // Handle exceptions
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Data da postagem
  String formatDate(String originalDate) {
    try {
      final parsedDate = DateTime.parse(originalDate).toLocal();
      final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(parsedDate);
      return formattedDate;
    } catch (e) {
      // Tratar erro ao fazer parse da data
      return "Data inválida";
    }
  }

  // Verifica se tem conexao
  Future<void> checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (mounted) {
      setState(() {
        isOnline = connectivityResult != ConnectivityResult.none;
      });
    }
  }

  // Atualizar Home
  Future<void> _refreshPosts() async {
    await fetchPosts();
  }

  Future<String> getPostId(String postId) async {
    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts/$postId?key=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['id'] != null) {
        return data['id'];
      } else {
        throw Exception("Post nao encontrado");
      }
    } else {
      throw Exception("Falha ao obter post");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    if (!isOnline) {
      // Verifica se esta conectado ou nao
      return ErrorScreen(
        onReload: () {
          setState(() {
            isOnline = true;
          });
          fetchPosts();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("News-Droid"),
        //Actions do tema escuro e claro
        actions: [
          IconButton(
            color: Colors.blue,
            icon: Icon(
                themeModel.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeModel.toggleDarkMode,
          ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading)
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: buildLoadingIndicator(),
              ),
            )
          else
            // GET data do blogger
            Expanded(
              child: RefreshIndicator.adaptive(
                color: Colors.blue,
                onRefresh: _refreshPosts,
                child: ListView.builder(
                  itemCount: filteredPosts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final post = filteredPosts[index];
                    final title = post['title'];
                    final url = post['url'];
                    final publishedDate = post['published'];
                    final formattedDate = formatDate(publishedDate);

                    var imageUrl =
                        post['images'] != null && post['images'].isNotEmpty
                            ? post['images'][0]['url']
                            : null;

                    if (imageUrl == null) {
                      final content = post['content'];
                      final match = RegExp(r'<img[^>]+src="([^">]+)"')
                          .firstMatch(content);
                      imageUrl = match?.group(1);
                    }

                    // Card da imagem e titulo da postagem
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.all(10.0),
                      // PostDetails
                      child: InkWell(
                        onTap: () async {
                          // Chame getPostId para buscar o postId da postagem atual
                          final postId = await getPostId(post['id']);
                          setState(() {
                            this.postId = postId;
                          });
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailsScreen(
                                title: title,
                                imageUrl: imageUrl,
                                content: post['content'],
                                url: url,
                                formattedDate: formattedDate,
                                blogId: blogId,
                                postId: postId,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(alignment: Alignment.bottomLeft, children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20.0),
                                  bottom: Radius.circular(20.0),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 4 / 2,
                                  child: imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: imageUrl ?? '',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child:
                                                Container(color: Colors.white),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error_outline),
                                        )
                                      : Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(color: Colors.white),
                                        ),
                                ),
                              ),
                            ]),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          size: 12,
                                          color: Colors
                                              .grey),
                                      const SizedBox(width: 4),
                                      Text(
                                       formattedDate,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
