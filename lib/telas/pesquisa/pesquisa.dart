import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:newsdroid/api/api.dart';
import 'package:newsdroid/telas/erro/erro.dart';
import 'package:newsdroid/telas/posts/posts_details.dart';
import 'package:newsdroid/widgets/shimmer_loading_pesquisa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> posts = [];
  List<dynamic> filteredPosts = [];
  String? postId;
  bool searchResultsEmpty = false;
  bool isOnline = true;
  bool isLoading = true;
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');
  int trendIndex = 0;
  final List<String> trendWords = [
    'Windows 12',
    'Android 15',
    'iOS 18',
    'GTA VI'
  ];

  @override
  void initState() {
    super.initState();
    fetchPosts();
    checkConnectivity();
    startTrendTimer();
  }

  Future<void> checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      isOnline = !connectivityResult.contains(ConnectivityResult.none);
    });
  }

  String formatDate(String originalDate) {
    final parsedDate = DateTime.parse(originalDate);
    final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(parsedDate);
    return formattedDate;
  }

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cachedPosts');
    if (cachedData != null) {
      final Map<String, dynamic> cachedPosts = jsonDecode(cachedData);
      final DateTime lastCachedTime =
          DateTime.parse(prefs.getString('cachedTime') ?? '');
      final DateTime currentTime = DateTime.now();
      final difference = currentTime.difference(lastCachedTime).inMinutes;
      if (difference < 30) {
        // reutiliza os dados em cache se forem menos de 30 minutos de idade
        setState(() {
          posts = cachedPosts['items'];
          filteredPosts = posts;
          isLoading = false;
        });
        return;
      }
    }
    try {
      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts?key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        prefs.setString('cachedPosts', response.body);
        prefs.setString(
          'cachedTime',
          DateTime.now().toString(),
        );
        setState(() {
          posts = data['items'];
          filteredPosts = posts;
          isLoading = false;
        });
      } else {
        throw Exception("Falha ao buscar postagens");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> getPostId(String postId) async {
    final response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts/$postId?key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['id'] != null) {
        return data['id'];
      } else {
        throw Exception("Nenhum post encontrado");
      }
    } else {
      throw Exception("Falha ao obter post");
    }
  }

  void searchPosts(String query) {
    if (query.isEmpty) {
      filteredPosts = posts;
      searchResultsEmpty = false;
      return;
    }

    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          filteredPosts = posts
              .where((post) =>
                  post['title'].toLowerCase().contains(query.toLowerCase()))
              .toList();

          searchResultsEmpty = filteredPosts.isEmpty;
        });
      }
    });
  }

  void startTrendTimer() {
    const trendDuration = Duration(seconds: 8);
    Timer.periodic(trendDuration, (Timer timer) {
      if (mounted) {
        setState(() {
          trendIndex = (trendIndex + 1) % trendWords.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isOnline) {
      return ErrorScreen(
        onReload: () {
          fetchPosts();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscar"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Card(
            margin: const EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: ValueListenableBuilder(
              builder: (BuildContext context, String query, Widget? child) {
                return TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    searchQuery.value = value;
                    searchPosts(value);
                  },
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.5,
                        color: Colors.transparent,
                      ),
                    ),
                    prefixIcon:
                        const Icon(Icons.search_outlined, color: Colors.blue),
                    border: InputBorder.none,
                    hintText: 'Procurar por "${trendWords[trendIndex]}"',
                    suffixIcon: searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_outlined),
                            onPressed: () {
                              _searchController.clear();
                              searchQuery.value = '';
                              searchPosts('');
                            },
                          )
                        : null,
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
      body: isLoading
          ? Center(child: buildShimmerLoadingSearch())
          : filteredPosts.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhum resultado encontrado 😱",
                    style: TextStyle(fontSize: 18.0),
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0,
                    mainAxisExtent: 300.0,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: filteredPosts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final post = filteredPosts[index];
                    final title = post['title'];
                    final url = post['url'];
                    final publishedDate = post['published'];
                    final formattedDate = formatDate(publishedDate);

                    var imageUrl = post['images'] != null
                        ? post['images'][0]['url']
                        : null;

                    if (imageUrl == null) {
                      final content = post['content'];
                      final match = RegExp(r'<img[^>]+src="([^">]+)"')
                          .firstMatch(content);
                      if (match != null) {
                        imageUrl = match.group(1);
                      }
                    }

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () async {
                          final postId = await getPostId(post['id']);
                          if (mounted) {
                            setState(() {
                              this.postId = postId;
                            });
                          }

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
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20.0),
                                bottom: Radius.circular(20.0),
                              ),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(color: Colors.white),
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          size: 12, color: Colors.grey),
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
    );
  }
}
