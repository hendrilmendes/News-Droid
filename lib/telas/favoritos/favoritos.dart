import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:newsdroid/models/favorito_model.dart';
import 'package:newsdroid/telas/posts/posts_details.dart';
import 'package:newsdroid/widgets/progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritePostsModel = Provider.of<FavoritePostsModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoritos"),
      ),
      body: favoritePostsModel.isLoading
          ? Center(
              child: buildLoadingIndicator(),
            )
          : favoritePostsModel.favoritePosts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Nenhum post favorito encontrado 😕",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: favoritePostsModel.favoritePosts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final post = favoritePostsModel.favoritePosts[index];
                    return Dismissible(
                      key: Key(post.postId),
                      onDismissed: (direction) {
                        favoritePostsModel.removeFavorite(post.postId);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child:
                              Icon(Icons.delete_outline, color: Colors.white),
                        ),
                      ),
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage(
                                imageUrl: post.imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(color: Colors.white),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error_outline),
                              ),
                            ),
                            title: Text(
                              post.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          size: 12,
                                          color: Colors
                                              .grey),
                                      const SizedBox(width: 4),
                                      Text(
                                       post.formattedDate,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
