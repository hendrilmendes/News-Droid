import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newsdroid/telas/erro/erro.dart';
import 'package:newsdroid/telas/posts/posts_details.dart';
import 'package:newsdroid/api/api.dart';
import 'package:newsdroid/tema/tema.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> posts = [];
  List<dynamic> filteredPosts = [];
  List<dynamic> favoritePosts = [];

  bool isDarkMode = false;
  int currentIndex = 0;
  bool isOnline = true;
  bool isLoading = false;
  bool searchResultsEmpty = false;
  Timer? _debounceTimer;
  Color progressIndicatorColor = Colors.blue;

  // Defina uma variável para armazenar o postId da postagem atual
  String? postId;

  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    fetchPosts();
    checkConnectivity();
  }

  // GET API
  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true; // Ativa o indicador de carregamento
    });

    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts?key=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        posts = data['items'];
        filteredPosts = posts;
        isLoading = false; // Desativando o indicador de carregamento
      });
    } else {
      // Caso ocorra um erro na requisição, desativa o indicador de carregamento
      setState(() {
        isLoading = false;
      });
    }
  }

  // Data da postagem
  String formatDate(String originalDate) {
    final parsedDate = DateTime.parse(originalDate);
    final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(parsedDate);
    return formattedDate;
  }

  // Verifica se tem conexao
  Future<void> checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      isOnline = connectivityResult != ConnectivityResult.none;
    });
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
        throw Exception('No post found');
      }
    } else {
      throw Exception('Failed to get post');
    }
  }

  // Carregamento dos posts
  Widget buildLoadingIndicator() {
    return CircularProgressIndicator.adaptive(
      backgroundColor: progressIndicatorColor,
    );
  }

  // Pesquisar Postagem
  void searchPosts(String query) {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        filteredPosts = posts
            .where((post) =>
                post['title'].toLowerCase().contains(query.toLowerCase()))
            .toList();

        // Define searchResultsEmpty como true se a lista de postagens filtradas estiver vazia
        searchResultsEmpty = filteredPosts.isEmpty;

        // Exibe a mensagem de erro usando Toast se a pesquisa não retornar resultados
        if (searchResultsEmpty) {
          showSearchErrorMessage();
        } else {
          // Caso haja resultados na pesquisa, o Toast e cancelado
          Fluttertoast.cancel();
        }
      });
    });
  }

  // Sem resultados
  void showSearchErrorMessage() {
    IconSnackBar.show(
        context: context,
        snackBarType: SnackBarType.fail,
        label: 'Nenhum resultado encontrado');
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    progressIndicatorColor = themeModel.isDarkMode ? Colors.blue : Colors.blue;

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
        title: const Text('News-Droid'),

        //Actions do tema escuro e claro
        actions: [
          IconButton(
            color: Colors.blue,
            icon: Icon(themeModel.isDarkMode
                ? CupertinoIcons.sun_max_fill
                : CupertinoIcons.moon_fill),
            onPressed: themeModel.toggleDarkMode,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Card(
            margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                100.0,
              ),
            ),
            child: SizedBox(
              height: 55.0,
              child: Center(
                child: ValueListenableBuilder(
                  builder: (BuildContext context, String query, Widget? child) {
                    return TextField(
                      controller: _searchController,
                      onChanged: (value) => searchPosts(value),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Colors.transparent,
                          ),
                        ),
                        prefixIcon:
                            Icon(CupertinoIcons.search, color: Colors.blue),
                        border: InputBorder.none,
                        hintText: 'Procurar por...',
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                    );
                  },
                  valueListenable: searchQuery,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (isLoading)
            Center(
              child: buildLoadingIndicator(),
            ),

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
                      post['images'] != null ? post['images'][0]['url'] : null;

                  if (imageUrl == null) {
                    final content = post['content'];
                    final match =
                        RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(content);
                    if (match != null) {
                      imageUrl = match.group(1);
                    }
                  }

                  // PostDetails
                  return InkWell(
                    onTap: () async {
                      // Chame getPostId para buscar o postId da postagem atual
                      final postId = await getPostId(post['id']);
                      setState(() {
                        this.postId = postId;
                      });
                      // ignore: use_build_context_synchronously
                      Navigator.push(
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

                    // Card da imagem e titulo da postagem
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10.0),
                              bottom: Radius.circular(10.0),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                              placeholder: (context, url) => Image.asset(
                                "assets/img/newsdroid.png",
                                width: double.infinity,
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error_outline),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
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
                                Text(
                                  "Publicado em $formattedDate", // Exibir a data formatada aqui
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
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
