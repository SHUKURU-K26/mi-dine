import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../models/dish.dart';
import '../../models/inputs.dart';

class DishFormSheet extends StatefulWidget {
  const DishFormSheet({super.key, required this.allergenNames, this.initial});

  /// Standard allergen names a dish can be tagged with.
  final List<String> allergenNames;
  final Dish? initial;

  @override
  State<DishFormSheet> createState() => _DishFormSheetState();
}

class _DishFormSheetState extends State<DishFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _description =
      TextEditingController(text: widget.initial?.description ?? '');
  late final _price = TextEditingController(
      text: widget.initial?.price?.toStringAsFixed(2) ?? '');
  late final Set<String> _contains = {...?widget.initial?.contains};
  late final Set<String> _may = {...?widget.initial?.mayContain};

  bool get _editing => widget.initial != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  /// none -> contains -> may contain -> none
  void _cycle(String name) {
    setState(() {
      if (_contains.contains(name)) {
        _contains.remove(name);
        _may.add(name);
      } else if (_may.contains(name)) {
        _may.remove(name);
      } else {
        _contains.add(name);
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      DishInput(
        name: _name.text,
        description: _description.text,
        price: double.tryParse(_price.text.trim()),
        contains: _contains.toList()..sort(),
        mayContain: _may.toList()..sort(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;

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
              Text(_editing ? 'Edit dish' : 'Add a dish',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 18),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                maxLength: 60,
                decoration:
                    const InputDecoration(labelText: 'Dish name', counterText: ''),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Dish name is required';
                  if (t.length < 2) return 'That name is too short';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 2,
                maxLength: 120,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Main ingredients (optional)', counterText: ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Price (optional)'),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return null;
                  final n = double.tryParse(t);
                  if (n == null || n < 0) return 'Enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Allergens in this dish',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                'Tap once for contains, twice for may contain traces, three times to clear.',
                style: TextStyle(color: pal.muted, fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final n in widget.allergenNames)
                    _TagChip(
                      label: n,
                      state: _contains.contains(n)
                          ? 1
                          : _may.contains(n)
                              ? 2
                              : 0,
                      onTap: () => _cycle(n),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                child: Text(_editing ? 'Save changes' : 'Add dish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;

  /// 0 none, 1 contains, 2 may contain.
  final int state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final color = switch (state) {
      1 => AppColors.unsafe,
      2 => AppColors.risky,
      _ => pal.muted,
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: state == 0 ? pal.surface : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: state == 0 ? pal.tint : color, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13.5, color: pal.text)),
            if (state != 0)
              Text(state == 1 ? 'Contains' : 'May contain',
                  style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}