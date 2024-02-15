import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:newsdroid/api/api.dart';
import 'package:newsdroid/helper/auth.dart';
import 'package:newsdroid/widgets/progress_indicator.dart';

class CommentScreen extends StatefulWidget {
  final String postId;

  const CommentScreen({required this.postId, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<Comment> comments = [];
  TextEditingController commentController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPostAndComments(widget.postId);
  }

  Future<void> fetchPostAndComments(String postId) async {
    final Uri commentsUri = Uri.parse(
        'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts/${widget.postId}/comments?key=$apiKey');
    final commentsResponse = await http.get(commentsUri);
    if (kDebugMode) {
      print("URL da solicitação: ${commentsUri.toString()}");
    }
    if (commentsResponse.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(commentsResponse.body);
      List<dynamic>? commentsData = data['items'];

      setState(() {
        if (commentsData != null && commentsData.isNotEmpty) {
          comments = commentsData
              .map(
                  (commentData) => Comment.fromJson(commentData, widget.postId))
              .toList();
          isLoading = false;
        } else {
          comments = [];
          isLoading = false;
        }
      });
    } else {
      if (kDebugMode) {
        print(
            "Falha ao buscar comentários. Código de status: ${commentsResponse.statusCode}");
      }
    }
  }

  Future<void> addComment(
    String commentText,
    String authorName,
    String authorAvatar,
    String commentDate,
    String postId,
  ) async {
    final oAuth2Helper = OAuth2Helper();
    final authorizationCode = await oAuth2Helper.getAuthorizationCode();

    if (authorizationCode != null) {
      final accessToken = await oAuth2Helper.getAccessToken(authorizationCode);

      final commentId = _generateUniqueId();
      final commentData = '''
      <entry xmlns='http://www.w3.org/2005/Atom'>
        <id>$commentId</id>
        <content type='text'>$commentText</content>
      </entry>
      ''';

      final response = await http.post(
        Uri.parse(
            'https://www.blogger.com/feeds/$blogId/${widget.postId}/comments/default'),
        headers: {
          'Content-Type': 'application/atom+xml',
          'Authorization': 'Bearer $accessToken',
        },
        body: commentData,
      );

      if (response.statusCode == 201) {
        if (kDebugMode) {
          print("Comentário adicionado com sucesso.");
        }
        setState(() {
          comments.add(Comment(
            content: commentText,
            authorName: authorName,
            authorAvatar: authorAvatar,
            postId: widget.postId,
            id: commentId,
            postDate: DateTime.now(),
          ));
          commentController.clear();
        });
      } else {
        if (kDebugMode) {
          print("Erro ao adicionar comentário.");
        }
        if (kDebugMode) {
          print("Response body: ${response.body}");
        }
        _showErrorDialog();
      }
    }
  }

  Future<void> _showErrorDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erro ao enviar comentário"),
          content: const Text(
              "Não foi possível enviar o comentário. Por favor, tente novamente mais tarde."),
          actions: <Widget>[
            FilledButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _generateUniqueId() {
    final bytes = utf8.encode('${DateTime.now()}');
    final digest = md5.convert(bytes);
    return digest.toString();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comentários"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: buildLoadingIndicator())
                : comments.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhum comentário disponível 😅",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      )
                    : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(comment.authorAvatar),
                            ),
                            title: Text(comment.authorName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.content),
                                Text(
                                  'Em: ${DateFormat('dd/MM/yyyy - HH:mm').format(comment.postDate.toLocal())}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Digite seu comentário..."),
                    ),
                  ),
                  IconButton(
                    color: Colors.blue,
                    icon: const Icon(Icons.send_outlined),
                    onPressed: () async {
                      final commentText = commentController.text;
                      const authorName = "Humano";
                      const authorAvatar =
                          'https://github.com/hendrilmendes/News-Droid/blob/main/assets/img/ic_launcher.png?raw=true';
                      final commentDate = DateTime.now().toString();
                      final postId = widget.postId;
                      addComment(
                        commentText,
                        authorName,
                        authorAvatar,
                        commentDate,
                        postId,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }
}

class Comment {
  final String authorName;
  final String content;
  final String authorAvatar;
  final String postId;
  final String id;
  final DateTime postDate;

  Comment({
    required this.authorName,
    required this.content,
    required this.authorAvatar,
    required this.postId,
    required this.id,
    required this.postDate,
  });

  factory Comment.fromJson(Map<String, dynamic> json, String postId) {
    final userImageUrl = json['author']['image']['url'];
    return Comment(
      id: json['id'],
      authorName: json['author']['displayName'],
      content: json['content'],
      authorAvatar: "https:$userImageUrl",
      postId: postId,
      postDate: DateTime.parse(json['published']),
    );
  }
}
