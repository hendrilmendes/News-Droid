import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsdroid/telas/posts/posts_details.dart';
import 'package:newsdroid/telas/config/config.dart';
import 'package:newsdroid/api/api.dart';
import 'package:newsdroid/tema/tema.dart';
import 'package:provider/provider.dart';

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

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  // GET API
  Future<void> fetchPosts() async {
    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts?key=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        posts = data['items'];
        filteredPosts = posts;
      });
    }
  }

  // Pesquisar Postagem
  void searchPosts(String query) {
    setState(() {
      filteredPosts = posts
          .where((post) =>
              post['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Data da postagem
  String formatDate(String originalDate) {
    final parsedDate = DateTime.parse(originalDate);
    final formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    return formattedDate;
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('News-Droid'),

        //Actions do tema escuro e claro
        actions: [
          IconButton(
            color: Colors.blue,
            icon: Icon(themeModel.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
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

          // GET data do blogger
          Expanded(
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

                  // Card da imgem e titulo da postagem
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
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(
                              value: 0.3,
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error_outline_outlined),
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
        ],
      ),

      // Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
