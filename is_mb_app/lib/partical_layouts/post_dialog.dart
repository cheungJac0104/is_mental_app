import 'package:flutter/material.dart';
import 'package:is_mb_app/models/string_extensions.dart';

part 'post_dialog_content.dart';
part 'post_dialog_style.dart';

class PostDialog {
  final BuildContext _context;
  final String _privacy;
  final String _content;

  PostDialog({
    required BuildContext context,
    required String privacy,
    required String content,
  })  : _context = context,
        _privacy = privacy,
        _content = content;

  BuildContext get context => _context;
  String get privacy => _privacy;
  String get content => _content;

  Future<bool?> show() async {
    return await showModalBottomSheet<bool>(
      context: _context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildDialogContent(content, privacy),
    );
  }
}
