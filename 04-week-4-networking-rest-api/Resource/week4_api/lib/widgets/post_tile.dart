import 'package:flutter/material.dart';
import '../data/models/post.dart';

/// Widget yang diekstrak dari ListView.builder agar builder
/// tetap pendek dan widget ini mudah diuji secara terpisah.
class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.post,
    this.onTap,
    this.showSubtitle = false,
  });

  final Post post;
  final VoidCallback? onTap;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(post.id.toString())),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: showSubtitle
          ? Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: onTap,
    );
  }
}
