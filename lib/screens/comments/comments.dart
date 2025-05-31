import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:newsdroid/api/api.dart';
import 'package:newsdroid/auth/auth.dart';
import 'package:newsdroid/l10n/app_localizations.dart';

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
      'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts/${widget.postId}/comments?key=$apiKey',
    );
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
                (commentData) => Comment.fromJson(commentData, widget.postId),
              )
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
          "Falha ao buscar comentários. Código de status: ${commentsResponse.statusCode}",
        );
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
      final commentData =
          '''
      <entry xmlns='http://www.w3.org/2005/Atom'>
        <id>$commentId</id>
        <content type='text'>$commentText</content>
      </entry>
      ''';

      final response = await http.post(
        Uri.parse(
          'https://www.blogger.com/feeds/$blogId/${widget.postId}/comments/default',
        ),
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
            "Erro ao adicionar comentário. Código de status: ${response.statusCode}",
          );
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
              'https://www.blogger.com/feeds/$blogId/${widget.postId}/comments/default/$commentId',
            ),
            headers: {'Authorization': 'Bearer $accessToken'},
          );

          if (response.statusCode == 200) {
            setState(() {
              comments.removeWhere((comment) => comment.id == commentId);
              isSubmitting = false;
            });
          } else {
            if (kDebugMode) {
              print(
                "Erro ao excluir comentário. Código de status: ${response.statusCode}",
              );
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
        title: Text(
          AppLocalizations.of(context)!.comments,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator.adaptive())
                : comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mode_comment_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.noComment,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      comment.authorAvatar,
                                    ),
                                    radius: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    comment.authorName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat(
                                      'HH:mm • dd/MM/yy',
                                    ).format(comment.postDate.toLocal()),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                comment.content,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () async {
                                    final authService = AuthService();
                                    final user = await authService
                                        .currentUser();
                                    if (user != null &&
                                        user.displayName ==
                                            comment.authorName) {
                                      await deleteComment(comment.id);
                                    } else {
                                      _showErrorDelete();
                                    }
                                  },
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
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: AppLocalizations.of(
                            context,
                          )!.hintTextComment,
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: IconButton(
                        icon: isSubmitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              )
                            : Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final commentText = commentController.text;
                                final authService = AuthService();
                                final user = await authService.currentUser();

                                if (user != null) {
                                  final authorName =
                                      user.displayName ??
                                      // ignore: use_build_context_synchronously
                                      AppLocalizations.of(context)!.human;
                                  final authorAvatar =
                                      user.photoURL ??
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
                                  await _showErrorDialog();
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
