import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AmountChips extends StatelessWidget {
  const AmountChips({required this.onSelected, super.key});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final amount in const ['1', '2', '5', '10', '20'])
          ActionChip(
            label: Text('\$$amount'),
            onPressed: () => onSelected(amount),
            backgroundColor: AppColors.surfaceTint,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      ],
    );
  }
}
