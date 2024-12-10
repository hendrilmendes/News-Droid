import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:newsdroid/api/api.dart';
import 'package:newsdroid/screens/error/error.dart';
import 'package:newsdroid/screens/posts/posts_details.dart';
import 'package:newsdroid/widgets/loading/shimmer_search.dart';
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
  bool searchResultsEmpty = false;
  bool isOnline = true;
  bool isLoading = true;
  Timer? _debounceTimer;
  int trendIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');
  bool showSearchBarAtBottom = true;
  List<String> allLabels = [];
  String? selectedLabel;

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
    loadSearchBarPosition();
  }

  Future<void> loadSearchBarPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showSearchBarAtBottom = prefs.getBool('searchBarPosition') ?? true;
    });
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
      if (difference < 5) {
        setState(() {
          posts = cachedPosts['items'];
          filteredPosts = posts;
          allLabels = _extractLabels(posts);
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
          allLabels = _extractLabels(posts);
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

  List<String> _extractLabels(List<dynamic> posts) {
    Set<String> labelsSet = {};
    for (var post in posts) {
      if (post['labels'] != null) {
        for (var label in post['labels']) {
          labelsSet.add(label);
        }
      }
    }
    return labelsSet.toList();
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
        title: Text(
          AppLocalizations.of(context)!.search,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (!showSearchBarAtBottom)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildSearchBar(),
            ),
          if (posts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 8.0,
                  children: allLabels.map<Widget>((label) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLabel = label;
                        });
                        filterPostsByLabel(label);
                      },
                      child: Chip(
                        label: Text(label),
                        backgroundColor: selectedLabel == label
                            ? Colors.blue
                            : Theme.of(context).listTileTheme.tileColor,
                        labelStyle: TextStyle(
                          color: selectedLabel == label
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: selectedLabel == label
                                ? Colors.blue
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          Expanded(
            child: isLoading
                ? Center(child: buildShimmerLoadingSearch())
                : filteredPosts.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)!.noResult,
                          style: const TextStyle(
                              fontSize: 18.0, color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          mainAxisExtent: 300,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
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
                            color: Theme.of(context).listTileTheme.tileColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                            margin: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () async {
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
                                      postId: post['id'],
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
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Container(
                                                    color: Colors.white),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                          Icons.error_outline),
                                            )
                                          : Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                  color: Colors.white),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
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
          if (showSearchBarAtBottom)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildSearchBar(),
            ),
        ],
      ),
    );
  }

  void filterPostsByLabel(String label) {
    setState(() {
      filteredPosts = posts
          .where((post) =>
              post['labels'] != null && post['labels'].contains(label))
          .toList();
      searchResultsEmpty = filteredPosts.isEmpty;
    });
  }

  Widget buildSearchBar() {
    return Card(
      color: Theme.of(context).listTileTheme.tileColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          searchQuery.value = value;
          searchPosts(value);
        },
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.5,
              color: Colors.transparent,
            ),
          ),
          prefixIcon: const Icon(Icons.search_outlined, color: Colors.blue),
          border: InputBorder.none,
          hintText:
              '${AppLocalizations.of(context)!.searchFor} "${trendWords[trendIndex]}"',
          suffixIcon: searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_outlined),
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
      ),
    );
  }
}
