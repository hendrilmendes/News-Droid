import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FavoritePostsModel extends ChangeNotifier {
  final Box _favoritePostsBox = Hive.box('favorite_posts');
  bool _isLoading = false;

  List<FavoritePost> get favoritePosts =>
      _favoritePostsBox.values.toList().cast<FavoritePost>();

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void addFavorite(FavoritePost post) {
    _favoritePostsBox.put(post.postId, post);
    notifyListeners();
  }

  void removeFavorite(String postId) {
    _favoritePostsBox.delete(postId);
    notifyListeners();
  }
}

class FavoritePost {
  final String postId;
  final String title;
  final String content;
  final String imageUrl;
  final String url;
  final String formattedDate;
  final String blogId;

  FavoritePost({
    required this.postId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.url,
    required this.formattedDate,
    required this.blogId,
  });
}
