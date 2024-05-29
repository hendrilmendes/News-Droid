import 'package:hive/hive.dart';
import 'package:newsdroid/models/favorite_model.dart';

class FavoritePostAdapter extends TypeAdapter<FavoritePost> {
  @override
  final int typeId = 0; // ID exclusivo para o adapter

  @override
  FavoritePost read(BinaryReader reader) {
    // le os dados do Hive e cria uma instância do FavoritePost
    Map fields = reader.readMap();
    return FavoritePost(
      postId: fields['postId'],
      title: fields['title'],
      content: fields['content'],
      imageUrl: fields['imageUrl'],
      url: fields['url'],
      formattedDate: fields['formattedDate'],
      blogId: fields['blogId'],
    );
  }

  @override
  void write(BinaryWriter writer, FavoritePost obj) {
    // escreve os dados do FavoritePost no Hive
    writer.writeMap({
      'postId': obj.postId,
      'title': obj.title,
      'content': obj.content,
      'imageUrl': obj.imageUrl,
      'url': obj.url,
      'formattedDate': obj.formattedDate,
      'blogId': obj.blogId,
    });
  }
}
