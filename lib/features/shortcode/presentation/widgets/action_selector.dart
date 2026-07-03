import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/shortcode_method.dart';

class ActionSelector extends StatelessWidget {
  const ActionSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ShortcodeMethod selected;
  final ValueChanged<ShortcodeMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ShortcodeMethod.values.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.38,
      ),
      itemBuilder: (context, index) {
        final method = ShortcodeMethod.values[index];
        final active = method == selected;

        return _ActionTile(
          method: method,
          active: active,
          onTap: () => onChanged(method),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.method,
    required this.active,
    required this.onTap,
  });

  final ShortcodeMethod method;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = active ? AppColors.ink : Colors.white;
    final fg = active ? Colors.white : AppColors.ink;
    final muted = active ? const Color(0xFFC9D6D1) : AppColors.mutedInk;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? AppColors.ink : const Color(0xFFE1E9E5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    method.icon,
                    color: active ? AppColors.lime : AppColors.emerald,
                  ),
                  const Spacer(),
                  Text(
                    method.menuCode,
                    style: TextStyle(
                      color: muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                method.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                method.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
