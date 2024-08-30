import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  void _imageTapped(
    BuildContext context,
    String title,
    String imageUrl,
    String url,
    String content,
    String formattedDate,
    String blogId,
    String postId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailsScreen(
          title: title,
          imageUrl: imageUrl,
          content: content,
          url: url,
          formattedDate: formattedDate,
          blogId: blogId,
          postId: postId,
        ),
      ),
    );
  }

  void _postTapped(int index) {
    final post = widget.filteredPosts[index];
    final title = post['title'] ?? 'Sem título';
    final url = post['url'] ?? '';
    final publishedDate = post['published'] ?? '';
    final formattedDate = widget.formatDate(publishedDate);

    var imageUrl = post['images']?.isNotEmpty == true
        ? post['images']![0]['url'] ?? ''
        : '';

    if (imageUrl.isEmpty) {
      final content = post['content'] ?? '';
      final match = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(content);
      imageUrl = match?.group(1) ?? '';
    }

    _imageTapped(
      context,
      title,
      imageUrl,
      url,
      post['content'] ?? '',
      formattedDate,
      post['blog']['id'] ?? '',
      post['id'] ?? '',
    );
  }

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
            child: CarouselView(
              itemExtent: 350,
              shrinkExtent: 200,
              itemSnapping: true,
              onTap: _postTapped,
              children: List<Widget>.generate(
                widget.filteredPosts.length >= 3
                    ? 3
                    : widget.filteredPosts.length,
                (int index) {
                  final post = widget.filteredPosts[index];
                  final title = post['title'] ?? 'Sem título';
                  final url = post['url'] ?? '';
                  final publishedDate = post['published'] ?? '';
                  final formattedDate = widget.formatDate(publishedDate);

                  var imageUrl = post['images']?.isNotEmpty == true
                      ? post['images']![0]['url'] ?? ''
                      : '';

                  if (imageUrl.isEmpty) {
                    final content = post['content'] ?? '';
                    final match =
                        RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(content);
                    imageUrl = match?.group(1) ?? '';
                  }

                  return Card(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: InkWell(
                      onTap: () => _imageTapped(
                        context,
                        title,
                        imageUrl,
                        url,
                        post['content'] ?? '',
                        formattedDate,
                        post['blog']['id'] ?? '',
                        post['id'] ?? '',
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: imageUrl.isNotEmpty
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_month_outlined,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.filteredPosts.length >= 3
                  ? widget.filteredPosts.length - 3
                  : 0,
              itemBuilder: (context, index) {
                final postIndex = index + 3;
                final post = widget.filteredPosts[postIndex];
                final title = post['title'] ?? 'Sem título';
                final url = post['url'] ?? '';
                final publishedDate = post['published'] ?? '';
                final formattedDate = widget.formatDate(publishedDate);

                var imageUrl = post['images']?.isNotEmpty == true
                    ? post['images']![0]['url'] ?? ''
                    : '';

                if (imageUrl.isEmpty) {
                  final content = post['content'] ?? '';
                  final match =
                      RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(content);
                  imageUrl = match?.group(1) ?? '';
                }

                return Card(
                  color: Theme.of(context).listTileTheme.tileColor,
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: InkWell(
                    onTap: () => _imageTapped(
                      context,
                      title,
                      imageUrl,
                      url,
                      post['content'] ?? '',
                      formattedDate,
                      post['blog']['id'] ?? '',
                      post['id'] ?? '',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: imageUrl.isNotEmpty
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
                                        Icons.calendar_month_outlined,
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
                                ]),
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
