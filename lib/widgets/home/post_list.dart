import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:newsdroid/screens/posts/posts_details.dart';

class PostListWidget extends StatefulWidget {
  final List<dynamic> filteredPosts;
  final int currentPage;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final Future<void> Function() onRefresh;
  final String Function(String) formatDate;

  const PostListWidget({
    super.key,
    required this.filteredPosts,
    required this.currentPage,
    required this.pageController,
    required this.onPageChanged,
    required this.onRefresh,
    required this.formatDate,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PostListWidgetState createState() => _PostListWidgetState();
}

class _PostListWidgetState extends State<PostListWidget> {
  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return RefreshIndicator(
      color: Colors.blue,
      onRefresh: widget.onRefresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: isTablet ? 300 : 200,
            child: PageView.builder(
              controller: widget.pageController,
              itemCount: widget.filteredPosts.length >= 3
                  ? 3
                  : widget.filteredPosts.length,
              onPageChanged: widget.onPageChanged,
              itemBuilder: (context, index) {
                final post = widget.filteredPosts[index];
                final title = post['title'];
                final url = post['url'];
                final publishedDate = post['published'];
                final formattedDate = widget.formatDate(publishedDate);

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
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailsScreen(
                            title: title,
                            imageUrl: imageUrl,
                            content: post['content'],
                            url: url,
                            formattedDate: formattedDate,
                            blogId: post['blog']['id'],
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
                        // selo de destaque
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.top,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
                widget.filteredPosts.length >= 3
                    ? 3
                    : widget.filteredPosts.length,
                (int index) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.currentPage == index
                          ? Colors.blue
                          : Colors.grey,
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
              itemCount: widget.filteredPosts.length >= 3
                  ? widget.filteredPosts.length - 3
                  : 0,
              itemBuilder: (context, index) {
                final postIndex = index + 3;
                final post = widget.filteredPosts[postIndex];
                final title = post['title'];
                final url = post['url'];
                final publishedDate = post['published'];
                final formattedDate = widget.formatDate(publishedDate);

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
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailsScreen(
                            title: title,
                            imageUrl: imageUrl,
                            content: post['content'],
                            url: url,
                            formattedDate: formattedDate,
                            blogId: post['blog']['id'],
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
                                      Iconsax.calendar,
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
