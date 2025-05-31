import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:newsdroid/l10n/app_localizations.dart';
import 'package:newsdroid/models/favorite_model.dart';
import 'package:newsdroid/screens/posts/posts_details.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritePostsModel = Provider.of<FavoritePostsModel>(context);

    Future<void> deleteAllFavorites() async {
      final appLocalizations = AppLocalizations.of(context);
      if (appLocalizations != null) {
        bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(appLocalizations.deleteFavorites),
              content: Text(appLocalizations.deleteFavoritesSub),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(appLocalizations.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(appLocalizations.delete),
                ),
              ],
            );
          },
        );

        if (confirmDelete == true) {
          favoritePostsModel.removeAllFavorites();
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.favorites,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: favoritePostsModel.isLoading
            ? Center(child: CircularProgressIndicator.adaptive())
            : favoritePostsModel.favoritePosts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.noFavorites,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              )
            : AnimatedList(
                key: GlobalKey<AnimatedListState>(),
                initialItemCount: favoritePostsModel.favoritePosts.length,
                itemBuilder:
                    (
                      BuildContext context,
                      int index,
                      Animation<double> animation,
                    ) {
                      final post = favoritePostsModel.favoritePosts[index];
                      return SizeTransition(
                        sizeFactor: animation,
                        child: Dismissible(
                          key: Key(post.postId),
                          onDismissed: (direction) {
                            favoritePostsModel.removeFavorite(post.postId);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            child: const Icon(
                              Icons.delete_outline_outlined,
                              color: Colors.white,
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.delete_outline_outlined,
                                color: Colors.white,
                              ),
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
                                title: Text(post.title),
                                subtitle: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 12,
                                      color: Colors.grey,
                                    ),
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
                        ),
                      );
                    },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppLocalizations.of(context)!.deleteFavorites,
        onPressed: deleteAllFavorites,
        child: const Icon(Icons.delete_outline_outlined),
      ),
    );
  }
}
