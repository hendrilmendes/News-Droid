import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:newsdroid/telas/erro/erro.dart';
import 'package:newsdroid/telas/posts/posts_details.dart';
import 'package:newsdroid/telas/config/config.dart';
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

  bool isDarkMode = false;
  int currentIndex = 0;
  bool isOnline = true;
  bool isLoading = false;
  bool searchResultsEmpty = false;
  Timer? _debounceTimer;
  Color progressIndicatorColor = Colors.blue;

  final TextEditingController _searchController = TextEditingController();

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
      // Caso ocorra um erro na requisição, desativamos o indicador de carregamento
      setState(() {
        isLoading = false;
      });
    }
  }

  // Data da postagem
  String formatDate(String originalDate) {
    final parsedDate = DateTime.parse(originalDate);
    final formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
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

  // Metodo da button nav
  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });

    if (index == 0) {
      currentIndex = 0;
    }

    if (index == 1) {
      currentIndex = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
  }

  // Sem resultados
  void showSearchErrorMessage() {
    FloatingSnackBar(
      message: 'Nenhum resultado encontrado 😭',
      context: context,
      textColor: Colors.black,
      textStyle: const TextStyle(color: Colors.blue),
      duration: const Duration(seconds: 3),
    );
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
          Padding(
            padding: const EdgeInsets.all(0.2),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => searchPosts(value),
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                prefixIcon: const Icon(CupertinoIcons.search),
                contentPadding: const EdgeInsets.only(bottom: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailsScreen(
                            title: title,
                            imageUrl: imageUrl,
                            content: post['content'],
                            url: url,
                            formattedDate: formattedDate,
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

      // Bottom Nav
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          shadowColor: Colors.blue,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: onTabTapped,
          selectedIndex: currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(CupertinoIcons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.settings),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}
