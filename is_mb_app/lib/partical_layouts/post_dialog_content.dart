part of 'post_dialog.dart';

DraggableScrollableSheet _buildDialogContent(String content, String privacy) {
  return DraggableScrollableSheet(
    initialChildSize: 0.4,
    minChildSize: 0.3,
    maxChildSize: 0.7,
    builder: (context, scrollController) {
      return Container(
        decoration: _dialogDecoration(context),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildDragHandle()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTitle(context),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                  const SizedBox(height: 16),
                  _buildPrivacyChip(context, privacy),
                  const SizedBox(height: 16),
                  if (content.isNotEmpty)
                    _buildContentPreview(context, content),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.1), // Spacer replacement
                ]),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildActionButtons(BuildContext context) {
  return Row(
    children: [
      _buildCancelButton(context),
      const SizedBox(width: 16),
      _buildPostButton(context),
    ],
  );
}
