import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:newsdroid/telas/erro/erro.dart';
import 'package:newsdroid/telas/posts/posts_details.dart';
import 'package:newsdroid/api/api.dart';
import 'package:newsdroid/widgets/shimmer_loading_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  bool isOnline = true;
  bool isLoading = false;
  PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    fetchPosts();
    checkConnectivity();
    _pageController = PageController(initialPage: 0);
    timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    timer.cancel();
    super.dispose();
  }

  // GET API
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
            'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts?key=$apiKey&maxResults=100'),
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

  String formatDate(String originalDate) {
    try {
      final parsedDate = DateTime.parse(originalDate).toLocal();
      return DateFormat('dd/MM/yyyy - HH:mm').format(parsedDate);
    } catch (e) {
      return "Data inválida";
    }
  }

  Future<void> checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      isOnline = !connectivityResult.contains(ConnectivityResult.none);
    });
  }

  Future<void> _refreshPosts() async {
    await fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    if (!isOnline) {
      return ErrorScreen(
        onReload: () {
          setState(() {
            isOnline = true;
          });
          _refreshPosts();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
      ),
      body: isLoading ? buildShimmerLoadingHome() : _buildPostList(),
    );
  }

  Widget _buildPostList() {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return RefreshIndicator(
      color: Colors.blue,
      onRefresh: _refreshPosts,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: isTablet ? 300 : 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: filteredPosts.length >= 3 ? 3 : filteredPosts.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                final title = post['title'];
                final url = post['url'];
                final publishedDate = post['published'];
                final formattedDate = formatDate(publishedDate);

                var imageUrl = post['images']?.isNotEmpty == true
                    ? post['images']![0]['url']
                    : null;

                if (imageUrl == null) {
                  final content = post['content'];
                  final match =
                      RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(content);
                  imageUrl = match?.group(1);
                }

                return Card(
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: InkWell(
                    onTap: () {
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
                            postId: post['id'],
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
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
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                filteredPosts.length >= 3 ? 3 : filteredPosts.length,
                (int index) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.blue : Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              AppLocalizations.of(context)!.lastNews,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount:
                  filteredPosts.length >= 3 ? filteredPosts.length - 3 : 0,
              itemBuilder: (context, index) {
                final postIndex = index + 3;
                final post = filteredPosts[postIndex];
                final title = post['title'];
                final url = post['url'];
                final publishedDate = post['published'];
                final formattedDate = formatDate(publishedDate);

                var imageUrl = post['images']?.isNotEmpty == true
                    ? post['images']![0]['url']
                    : null;

                if (imageUrl == null) {
                  final content = post['content'];
                  final match =
                      RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(content);
                  imageUrl = match?.group(1);
                }

                return Card(
                  color: Theme.of(context).listTileTheme.tileColor,
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: InkWell(
                    onTap: () {
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
                            postId: post['id'],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: SizedBox(
                              width: 100,
                              height: 100,
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 12,
                                      color: Colors.grey,
                                    ),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
