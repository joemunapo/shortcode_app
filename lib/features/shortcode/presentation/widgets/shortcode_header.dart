import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ShortcodeHeader extends StatelessWidget {
  const ShortcodeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    final headerTopPadding = topInset < 62 ? 80.0 : topInset + 18;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
        padding: EdgeInsets.fromLTRB(20, headerTopPadding, 20, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset('assets/images/app_icon.png'),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Shortcode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'USD',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Build. Preview. Dial.',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Fast EcoCash agent shortcodes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFC9D6D1),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
