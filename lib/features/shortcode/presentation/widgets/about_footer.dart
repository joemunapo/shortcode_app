import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/platform/native_phone_service.dart';
import '../../../../core/theme/app_theme.dart';

class AboutFooter extends StatelessWidget {
  const AboutFooter({
    required this.phoneService,
    required this.onError,
    super.key,
  });

  final NativePhoneService phoneService;
  final ValueChanged<String> onError;

  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=shortcode.fintraqr.com';
  static const _githubUrl = 'https://github.com/joemunapo';
  static const _xUrl = 'https://x.com/joemunapo';
  static const _shareText =
      'I use Shortcode for quick EcoCash agent codes: $_playStoreUrl\n\nBuilt by Joe Munapo, who makes custom apps, dashboards, websites, and automation for businesses.\nGitHub: $_githubUrl\nX: $_xUrl';

  Future<void> _share() async {
    try {
      await phoneService.shareText(_shareText);
    } on PlatformException catch (error) {
      onError(error.message ?? 'Could not open sharing.');
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      await phoneService.openUrl(url);
    } on PlatformException catch (error) {
      onError(error.message ?? 'Could not open the link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Built by Joe Munapo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mutedInk,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Custom apps, dashboards, websites, and automation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mutedInk,
              fontSize: 11,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            children: [
              _FooterAction(
                icon: Icons.ios_share_rounded,
                label: 'Share',
                onTap: _share,
              ),
              _FooterAction(
                icon: Icons.code_rounded,
                label: 'GitHub',
                onTap: () => _openUrl(_githubUrl),
              ),
              _FooterAction(
                icon: Icons.alternate_email_rounded,
                label: 'X',
                onTap: () => _openUrl(_xUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.emerald,
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}
