import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.validator,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: widget.isPassword && _hidden,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, size: 20, color: AppColors.primary),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _hidden ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}