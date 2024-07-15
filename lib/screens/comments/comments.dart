import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:newsdroid/api/api.dart';
import 'package:newsdroid/auth/auth.dart';
import 'package:newsdroid/widgets/loading/shimmer_comments.dart';

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
  bool isSubmitting = false;

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
    setState(() {
      isSubmitting = true; // Inicia a animação de envio
    });

    final authService = AuthService();
    final googleSignInAccount = await authService.googleSignInAccount;

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;
      final accessToken = googleAuth.accessToken;

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
        await fetchPostAndComments(widget.postId);

        setState(() {
          isSubmitting = false;
          commentController.clear();
        });
      } else {
        if (kDebugMode) {
          print(
              "Erro ao adicionar comentário. Código de status: ${response.statusCode}");
        }
        if (kDebugMode) {
          print("Response body: ${response.body}");
        }
        setState(() {
          isSubmitting = false;
        });
        _showErrorDialog();
      }
    } else {
      if (kDebugMode) {
        print("Usuário não está autenticado.");
      }
      setState(() {
        isSubmitting = false;
      });
      _showErrorDialog();
    }
  }

  Future<void> deleteComment(String commentId) async {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      final bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(appLocalizations.confirmDelete),
            content: Text(appLocalizations.confirmDeleteSub),
            actions: <Widget>[
              TextButton(
                child: Text(appLocalizations.cancel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FilledButton.tonal(
                child: Text(appLocalizations.delete),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirmDelete) {
        setState(() {
          isSubmitting = true;
        });

        final authService = AuthService();
        final googleSignInAccount = await authService.googleSignInAccount;

        if (googleSignInAccount != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleSignInAccount.authentication;
          final accessToken = googleAuth.accessToken;

          final response = await http.delete(
            Uri.parse(
                'https://www.blogger.com/feeds/$blogId/${widget.postId}/comments/default/$commentId'),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          );

          if (response.statusCode == 200) {
            setState(() {
              comments.removeWhere((comment) => comment.id == commentId);
              isSubmitting = false;
            });
          } else {
            if (kDebugMode) {
              print(
                  "Erro ao excluir comentário. Código de status: ${response.statusCode}");
            }
            _showErrorDelete();
            setState(() {
              isSubmitting = false;
            });
          }
        } else {
          if (kDebugMode) {
            print("Usuário não está autenticado.");
          }
          _showErrorDelete();
          setState(() {
            isSubmitting = false;
          });
        }
      }
    }
  }

  Future<void> _showErrorDelete() async {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(appLocalizations.errorCommentsDelete),
            content: Text(appLocalizations.errorCommentsDeleteSub),
            actions: <Widget>[
              FilledButton(
                child: Text(appLocalizations.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showErrorDialog() async {
    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations != null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(appLocalizations.errorComments),
            content: Text(appLocalizations.errorCommentsSub),
            actions: <Widget>[
              FilledButton(
                child: Text(appLocalizations.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
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
        title: Text(AppLocalizations.of(context)!.comments),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(
                    child: buildShimmerLoadingComments(),
                  )
                : comments.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)!.noComment,
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      )
                    : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return Card(
                            clipBehavior: Clip.hardEdge,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(comment.authorAvatar),
                              ),
                              title: Text(comment.authorName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(comment.content),
                                  Row(
                                    children: [
                                      const Icon(Iconsax.calendar,
                                          size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('dd/MM/yyyy - HH:mm')
                                            .format(comment.postDate.toLocal()),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Iconsax.trash),
                                onPressed: () async {
                                  final authService = AuthService();
                                  final user = await authService.currentUser();
                                  if (user != null &&
                                      user.displayName == comment.authorName) {
                                    await deleteComment(comment.id);
                                  } else {
                                    _showErrorDelete();
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Card(
            color: Theme.of(context).listTileTheme.tileColor,
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
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              AppLocalizations.of(context)!.hintTextComment),
                    ),
                  ),
                  IconButton(
                    color: Colors.blue,
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 24.0,
                            height: 24.0,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Icon(Iconsax.send1),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final commentText = commentController.text;
                            final authService = AuthService();
                            final user = await authService.currentUser();

                            if (user != null) {
                              if (kDebugMode) {
                                print(
                                    "Usuário autenticado: ${user.displayName}");
                              }
                              final authorName = user.displayName ??
                                  // ignore: use_build_context_synchronously
                                  AppLocalizations.of(context)!.human;
                              final authorAvatar = user.photoURL ??
                                  'https://github.com/hendrilmendes/News-Droid/blob/main/assets/img/ic_launcher.png?raw=true';
                              final commentDate = DateTime.now().toString();
                              final postId = widget.postId;
                              await addComment(
                                commentText,
                                authorName,
                                authorAvatar,
                                commentDate,
                                postId,
                              );
                            } else {
                              if (kDebugMode) {
                                print("Nenhum usuário autenticado encontrado.");
                              }
                              await _showErrorDialog();
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
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
