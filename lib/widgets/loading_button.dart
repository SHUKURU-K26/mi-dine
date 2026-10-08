import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Button whose label cross-fades into a spinner while loading.
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoading
            ? const CupertinoActivityIndicator(
                key: ValueKey('spinner'), color: Colors.white)
            : Text(label, key: const ValueKey('label')),
      ),
    );
  }
}