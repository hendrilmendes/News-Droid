import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newsdroid/models/favorito_model.dart';
import 'package:newsdroid/telas/posts/posts_details.dart';
import 'package:newsdroid/widgets/progress_indicator.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoritePostsModel = Provider.of<FavoritePostsModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: favoritePostsModel.favoritePosts.isEmpty
          ? const Center(
              child: Text(
                'Nenhum post favorito encontrado 😕',
                style: TextStyle(fontSize: 22),
              ),
            )
          : ListView.builder(
              itemCount: favoritePostsModel.favoritePosts.length,
              itemBuilder: (context, index) {
                final post = favoritePostsModel.favoritePosts[index];
                return Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10.0),
                        bottom: Radius.circular(10.0),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl,
                        placeholder: (context, url) => buildLoadingIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error_outline),
                      ),
                    ),
                    title: Text(post.title),
                    subtitle: Text(post.formattedDate),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => PostDetailsScreen(
                            postId: post.postId,
                            title: post.title,
                            content: post.content,
                            imageUrl: post.imageUrl,
                            url: post.url,
                            formattedDate: post.formattedDate,
                            blogId: post.blogId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
