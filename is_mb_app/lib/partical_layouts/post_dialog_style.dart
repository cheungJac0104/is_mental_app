part of 'post_dialog.dart';

BoxDecoration _dialogDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 20,
        spreadRadius: 5,
      ),
    ],
  );
}

Widget _buildDragHandle() {
  return Container(
    margin: const EdgeInsets.only(top: 12, bottom: 8),
    width: 40,
    height: 5,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

Widget _buildTitle(BuildContext context) {
  return Text(
    'Share Post',
    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
  );
}

Widget _buildPrivacyChip(BuildContext context, String privacy) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      "Permission : ${privacy.capitalize()}",
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget _buildContentPreview(BuildContext context, String content) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).shadowColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      content,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget _buildCancelButton(BuildContext context) {
  return Expanded(
    child: OutlinedButton(
      onPressed: () => Navigator.pop(context, false),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Cancel'),
    ),
  );
}

Widget _buildPostButton(BuildContext context) {
  return Expanded(
    child: FilledButton(
      onPressed: () => Navigator.pop(context, true),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Post'),
    ),
  );
}
