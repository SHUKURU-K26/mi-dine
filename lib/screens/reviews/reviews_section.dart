import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mi_dine/core/theme/app_palette.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/error_text.dart';
import '../../models/review.dart';
import '../../repositories/restaurant_repository.dart';
import '../../state/auth_provider.dart';
import '../../state/restaurant_provider.dart';
import '../../widgets/error_state.dart';
import '../../widgets/skeleton_box.dart';
import '../../widgets/star_rating.dart';
import 'review_sheet.dart';

class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(reviewsProvider(restaurantId));
    final uid = ref.watch(currentUserIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Safety reviews',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            TextButton.icon(
              onPressed: () => _write(context),
              icon: Icon(CupertinoIcons.pencil, size: 18),
              label: Text('Write'),
            ),
          ],
        ),
        SizedBox(height: 8),
        reviews.when(
          loading: () => const SkeletonBox(height: 110),
          error: (e, _) => ErrorState(
            message: friendlyError(e),
            onRetry: () => ref.invalidate(reviewsProvider(restaurantId)),
          ),
          data: (list) {
            if (list.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.pal.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.pal.tint, width: 1.5),
                ),
                child: Text(
                  'No reviews yet. Be the first to share how this kitchen handled your dietary needs.',
                  style: TextStyle(color: context.pal.muted, height: 1.45),
                ),
              );
            }
            return Column(
              children: [
                _Summary(reviews: list),
                SizedBox(height: 12),
                for (final review in list)
                  _ReviewCard(
                    review: review,
                    isMine: review.userId == uid,
                    onDelete: () => _delete(context, ref, review),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _write(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final posted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.pal.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReviewSheet(restaurantId: restaurantId),
    );
    if (posted == true) {
      messenger.showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.safe,
        content: Text('Thank you. Your review is live.'),
      ));
    }
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Review review) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Delete review?'),
        content: Text('This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(restaurantRepositoryProvider).deleteReview(review.id);
      ref.invalidate(reviewsProvider(restaurantId));
      messenger.showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
        content: Text('Review deleted'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.unsafe,
        content: Text(friendlyError(e)),
      ));
    }
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.reviews});

  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    final avg =
        reviews.fold<int>(0, (sum, r) => sum + r.rating) / reviews.length;
    final fryer = reviews.where((r) => r.dedicatedFryer).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.pal.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(avg.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: context.pal.strong)),
              StarRating(rating: avg.round(), size: 14),
            ],
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              '$fryer of ${reviews.length} ${reviews.length == 1 ? 'reviewer' : 'reviewers'} confirmed a dedicated fryer.',
              style: TextStyle(
                  color: context.pal.strong, height: 1.4, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.isMine,
    required this.onDelete,
  });

  final Review review;
  final bool isMine;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final d = review.createdAt.toLocal();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.pal.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.pal.tint, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: context.pal.tint,
                child: Text(review.authorName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                        color: context.pal.accent, fontWeight: FontWeight.w700)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.authorName,
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('${d.day}/${d.month}/${d.year}',
                        style: TextStyle(
                            color: context.pal.muted, fontSize: 12)),
                  ],
                ),
              ),
              StarRating(rating: review.rating, size: 14),
              if (isMine)
                IconButton(
                  tooltip: 'Delete review',
                  icon: Icon(CupertinoIcons.trash,
                      size: 18, color: AppColors.unsafe),
                  onPressed: onDelete,
                ),
            ],
          ),
          if (review.dedicatedFryer || review.staffKnowledgeable) ...[
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (review.dedicatedFryer) const _Tag('Dedicated fryer'),
                if (review.staffKnowledgeable) const _Tag('Knowledgeable staff'),
              ],
            ),
          ],
          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 10),
            Text(review.comment, style: TextStyle(height: 1.45)),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.safe.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.checkmark_alt,
              size: 14, color: AppColors.safe),
          SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.safe)),
        ],
      ),
    );
  }
}