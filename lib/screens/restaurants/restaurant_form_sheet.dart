import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/validators.dart';
import '../../models/inputs.dart';
import '../../models/restaurant.dart';

/// Used to add a new restaurant and to edit an existing one.
class RestaurantFormSheet extends StatefulWidget {
  const RestaurantFormSheet({super.key, this.initial});

  final Restaurant? initial;

  @override
  State<RestaurantFormSheet> createState() => _RestaurantFormSheetState();
}

class _RestaurantFormSheetState extends State<RestaurantFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _cuisine =
      TextEditingController(text: widget.initial?.cuisine ?? '');
  late final _address =
      TextEditingController(text: widget.initial?.address ?? '');
  late final _description =
      TextEditingController(text: widget.initial?.description ?? '');

  bool get _editing => widget.initial != null;

  @override
  void dispose() {
    _name.dispose();
    _cuisine.dispose();
    _address.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      RestaurantInput(
        name: _name.text,
        cuisine: _cuisine.text,
        address: _address.text,
        description: _description.text,
      ),
    );
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
              Text(_editing ? 'Edit restaurant' : 'Add a restaurant',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Other members will see it marked as member added and unverified.',
                style: TextStyle(color: context.pal.muted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                maxLength: 60,
                decoration:
                    const InputDecoration(labelText: 'Name', counterText: ''),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Name is required';
                  if (t.length < 2) return 'That name is too short';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cuisine,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Cuisine', hintText: 'For example: Italian'),
                validator: (v) => Validators.required(v, 'Cuisine'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => Validators.required(v, 'Address'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 3,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Short description (optional)'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _submit,
                child: Text(_editing ? 'Save changes' : 'Add restaurant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}