import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:newsdroid/screens/error/error.dart';
import 'package:newsdroid/api/api.dart';
import 'package:newsdroid/widgets/home/post_list.dart';
import 'package:newsdroid/widgets/loading/shimmer_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late PageController _pageController;
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
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
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
      if (difference < 5) {
        // reutiliza os dados em cache se forem menos de 5 minutos de idade
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
      body: isLoading
          ? buildShimmerLoadingHome()
          : PostListWidget(
              filteredPosts: filteredPosts,
              currentPage: _currentPage,
              pageController: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              onRefresh: _refreshPosts,
              formatDate: formatDate,
            ),
    );
  }
}
