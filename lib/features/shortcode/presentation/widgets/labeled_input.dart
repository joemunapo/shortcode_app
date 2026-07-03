import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabeledInput extends StatelessWidget {
  const LabeledInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.keyboardType,
    this.inputFormatters = const [],
    this.trailing,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
