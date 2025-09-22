import 'package:flutter/material.dart';

class Customtextfield extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final String hintText;
  final Widget suffixIcon;
  final String? helperText;
  final String? Function(String?)? validator;
  final bool? enabled;

  const Customtextfield({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.keyboardType,
    required this.hintText,
    required this.suffixIcon,
    this.helperText,
    this.validator, this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        helperText: helperText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
        filled: enabled == false,
        fillColor: enabled == false ? Colors.grey[100] : null,
      ),
    );
  }
}
