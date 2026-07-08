import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/saved_target.dart';

class SavedTargetChips extends StatelessWidget {
  const SavedTargetChips({
    required this.type,
    required this.entries,
    required this.onSelected,
    required this.onLongPress,
    super.key,
  });

  static const _namedTint = Color(0xFFDDF2EE);

  final TargetType type;
  final List<SavedTarget> entries;
  final ValueChanged<SavedTarget> onSelected;
  final ValueChanged<SavedTarget> onLongPress;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved & recent — tap to fill, hold to edit',
          style: TextStyle(
            color: AppColors.mutedInk,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final entry in entries) _chip(entry)],
        ),
      ],
    );
  }

  Widget _chip(SavedTarget entry) {
    final label = entry.isNamed
        ? (entry.nickname ?? entry.name)
        : formatTargetValue(type, entry.value);

    return Material(
      color: entry.isNamed ? _namedTint : AppColors.surfaceTint,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onSelected(entry),
        onLongPress: () => onLongPress(entry),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.isNamed) ...[
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppColors.emerald,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
