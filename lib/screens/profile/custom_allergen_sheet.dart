import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/severity_style.dart';
import '../../models/severity.dart';

class CustomAllergenResult {
  const CustomAllergenResult(this.name, this.severity);

  final String name;
  final Severity severity;
}

/// Used both to add a new custom ingredient and to edit an existing one.
class CustomAllergenSheet extends StatefulWidget {
  const CustomAllergenSheet({
    super.key,
    required this.takenNames,
    this.initialName,
    this.initialSeverity,
  });

  /// Lower-case names already in the list, to block duplicates.
  final Set<String> takenNames;
  final String? initialName;
  final Severity? initialSeverity;

  @override
  State<CustomAllergenSheet> createState() => _CustomAllergenSheetState();
}

class _CustomAllergenSheetState extends State<CustomAllergenSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName ?? '');
  late Severity _severity = widget.initialSeverity ?? Severity.severe;

  bool get _editing => widget.initialName != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter the ingredient name';
    if (text.length < 2) return 'That name is too short';
    if (text.length > 40) return 'Keep it under 40 characters';
    final lower = text.toLowerCase();
    if (lower != widget.initialName?.toLowerCase() &&
        widget.takenNames.contains(lower)) {
      return 'This ingredient is already in your list';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, CustomAllergenResult(_name.text.trim(), _severity));
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
              Text(_editing ? 'Edit ingredient' : 'Add your own ingredient',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Only you can see this. On your ticket it appears exactly as you type it, so write it in the kitchen\'s language if you can.',
                style: TextStyle(color: pal.muted, height: 1.4, fontSize: 13),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _name,
                autofocus: !_editing,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 40,
                validator: _validate,
                decoration: const InputDecoration(
                  labelText: 'Ingredient name',
                  hintText: 'For example: Kiwi, Mustard, Lupin',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              Text('How serious is this for you?',
                  style: TextStyle(color: pal.muted)),
              const SizedBox(height: 10),
              for (final s in Severity.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _severity = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: _severity == s
                            ? s.color.withValues(alpha: 0.10)
                            : pal.surface,
                        border: Border.all(
                          color: _severity == s ? s.color : pal.tint,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(s.icon, color: s.color, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(s.label,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: pal.text)),
                          ),
                          if (_severity == s)
                            Icon(CupertinoIcons.checkmark_alt, color: s.color),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _submit,
                child: Text(_editing ? 'Save changes' : 'Add to my profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}