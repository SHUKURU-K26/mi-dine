import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mi_dine/core/theme/app_palette.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/error_text.dart';
import '../../repositories/restaurant_repository.dart';
import '../../state/restaurant_provider.dart';
import '../../widgets/loading_button.dart';

class ReviewSheet extends ConsumerStatefulWidget {
  const ReviewSheet({super.key, required this.restaurantId});
 
  final String restaurantId;

  @override
  ConsumerState<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<ReviewSheet> {
  final _formKey = GlobalKey<FormState>();
  final _comment = TextEditingController();
  int _rating = 0;
  bool _fryer = false;
  bool _staff = false;
  bool _loading = false;
  bool _ratingError = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    setState(() => _ratingError = _rating == 0);
    if (!valid || _rating == 0) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(restaurantRepositoryProvider).addReview(
            restaurantId: widget.restaurantId,
            rating: _rating,
            comment: _comment.text,
            dedicatedFryer: _fryer,
            staffKnowledgeable: _staff,
          );
      ref.invalidate(reviewsProvider(widget.restaurantId));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Write a safety review',
                  style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 4),
              Text('Help others with the same needs eat safely.',
                  style: TextStyle(color: context.pal.muted)),
              SizedBox(height: 20),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    GestureDetector(
                      onTap: () => setState(() {
                        _rating = i;
                        _ratingError = false;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnimatedScale(
                          scale: i <= _rating ? 1.15 : 1,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            i <= _rating
                                ? CupertinoIcons.star_fill
                                : CupertinoIcons.star,
                            size: 34,
                            color: AppColors.risky,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (_ratingError)
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Please choose a rating',
                      style: TextStyle(color: AppColors.unsafe, fontSize: 12)),
                ),
              SizedBox(height: 16),
              _SwitchRow(
                label: 'The kitchen used a dedicated fryer or prep area',
                value: _fryer,
                onChanged: (v) => setState(() => _fryer = v),
              ),
              _SwitchRow(
                label: 'Staff understood my dietary needs',
                value: _staff,
                onChanged: (v) => setState(() => _staff = v),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _comment,
                maxLines: 4,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'How did the kitchen handle your needs?',
                ),
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return 'Please write a short comment';
                  if (text.length < 10) return 'Add a little more detail';
                  return null;
                },
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!,
                      style: TextStyle(color: AppColors.unsafe)),
                ),
              SizedBox(height: 8),
              LoadingButton(
                label: 'Post review',
                onPressed: _submit,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(height: 1.35))),
          SizedBox(width: 12),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}