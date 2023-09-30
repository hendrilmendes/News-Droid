import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:newsdroid/api/api.dart';
import 'package:newsdroid/telas/captcha/captcha.dart';
import 'package:newsdroid/widgets/adaptative_action.dart';
import 'package:newsdroid/widgets/progress_indicator.dart';

class CommentScreen extends StatefulWidget {
  final String postId; // Adicione um campo para o postId

  const CommentScreen({required this.postId, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<Comment> comments = [];
  TextEditingController commentController = TextEditingController();
  bool isLoading = true; // Variável para controlar o estado de carregamento

  @override
  void initState() {
    super.initState();
    fetchPostAndComments(widget.postId); // Passando o postId
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
      List<dynamic> commentsData = data['items'];

      setState(() {
        comments = commentsData
            .map((commentData) => Comment.fromJson(commentData, widget.postId))
            .toList();
        isLoading = false; // Marca o carregamento como concluído.
      });
    }
  }

  Future<void> addComment(String commentText, String authorName,
      String authorAvatar, String commentDate, String postId) async {
    final commentData = '''
    <entry xmlns='http://www.w3.org/2005/Atom'>
      <content type='text'>$commentText</content>
    </entry>
    ''';

    final response = await http.post(
      Uri.parse(
          'https://www.blogger.com/feeds/$blogId/$postId/comments/default'),
      headers: {
        'Content-Type': 'application/atom+xml',
        'Authorization': 'Bearer $apiKey',
      },
      body: commentData,
    );

    if (response.statusCode == 201) {
      // Comentário adicionado com sucesso.
      if (kDebugMode) {
        print('Comentário adicionado com sucesso.');
      }
      setState(() {
        comments.add(Comment(
          content: commentText,
          authorName: authorName,
          authorAvatar: authorAvatar,
          postId: widget.postId,
          postDate: DateTime.now(),
        ));
        commentController.clear();
      });
    } else {
      // Algo deu errado ao adicionar o comentário.
      if (kDebugMode) {
        print('Erro ao adicionar comentário.');
      }
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }
      // Exibe o diálogo de erro.
      _showErrorDialog();
    }
  }

  // ignore: non_constant_identifier_names
  Icon _SendIcon() {
    if (Platform.isAndroid) {
      return const Icon(Icons.send_outlined);
    } else {
      return const Icon(CupertinoIcons.arrow_up_circle_fill);
    }
  }

  Future<void> _showErrorDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text("Erro ao enviar o comentário"),
          content: const Text(
              "Não foi possível enviar o comentário. Por favor, tente novamente mais tarde."),
          actions: <Widget>[
            adaptiveAction(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
              context: context,
            ),
          ],
        );
      },
    );
  }

  Future<void> openCaptchaPage() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resolva o CAPTCHA'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // Defina a altura apropriada para o WebView
            child: CaptchaPage(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Feche o diálogo se necessário.
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addCommentWithCaptcha(
    String commentText,
    String authorName,
    String authorAvatar,
    String commentDate,
    String postId,
  ) async {
    // Abra a página de CAPTCHA antes de enviar o comentário
    await openCaptchaPage();

    // Após o usuário resolver o CAPTCHA, adicione o comentário aqui
    addComment(commentText, authorName, authorAvatar, commentDate, postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentários'),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: buildLoadingIndicator())
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(comment.authorAvatar),
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
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.5,
                              color: Colors.transparent,
                            ),
                          ),
                          border: InputBorder.none,
                          hintText: 'Digite seu comentário...'),
                    ),
                  ),
                  IconButton(
                    color: Colors.blue,
                    icon: _SendIcon(),
                    onPressed: () async {
                      final commentText = commentController.text;
                      const authorName = 'Humano';
                      const authorAvatar =
                          'https://banner2.cleanpng.com/20180623/iqh/kisspng-computer-icons-avatar-social-media-blog-font-aweso-avatar-icon-5b2e99c40ce333.6524068515297806760528.jpg';
                      final commentDate = DateTime.now().toString();
                      final postId = widget.postId;
                      addComment(commentText, authorName, authorAvatar,
                          commentDate, postId);
                      openCaptchaPage();
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
  final DateTime postDate;

  Comment({
    required this.authorName,
    required this.content,
    required this.authorAvatar,
    required this.postId,
    required this.postDate,
  });

  factory Comment.fromJson(Map<String, dynamic> json, String postId) {
    final userImageUrl = json['author']['image']['url'];
    return Comment(
      authorName: json['author']['displayName'],
      content: json['content'],
      authorAvatar: "https:$userImageUrl",
      postId: postId,
      postDate: DateTime.parse(json['published']),
    );
  }
}
