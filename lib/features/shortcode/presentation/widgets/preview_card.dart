import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class PreviewCard extends StatelessWidget {
  const PreviewCard({
    required this.code,
    required this.isValid,
    required this.onDial,
    super.key,
  });

  final String code;
  final bool isValid;
  final VoidCallback onDial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E9E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'USSD preview',
                style: TextStyle(
                  color: AppColors.mutedInk,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: isValid ? AppColors.emerald : const Color(0xFFCBD5D1),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            code,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onDial,
            icon: const Icon(Icons.phone_rounded),
            label: const Text('Dial shortcode'),
          ),
        ],
      ),
    );
  }
}
