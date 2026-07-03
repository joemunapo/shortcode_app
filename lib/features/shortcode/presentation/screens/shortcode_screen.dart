import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/platform/native_phone_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/shortcode_builder.dart';
import '../../domain/shortcode_method.dart';
import '../widgets/action_selector.dart';
import '../widgets/amount_chips.dart';
import '../widgets/about_footer.dart';
import '../widgets/labeled_input.dart';
import '../widgets/preview_card.dart';
import '../widgets/shortcode_header.dart';

class ShortcodeScreen extends StatefulWidget {
  const ShortcodeScreen({super.key});

  @override
  State<ShortcodeScreen> createState() => _ShortcodeScreenState();
}

class _ShortcodeScreenState extends State<ShortcodeScreen> {
  final _targetController = TextEditingController();
  final _amountController = TextEditingController();
  final _builder = const ShortcodeBuilder();
  final _phoneService = const NativePhoneService();

  ShortcodeMethod _method = ShortcodeMethod.agentToAgent;
  ShortcodeBuildResult _result = const ShortcodeBuildResult.invalid(
    'Enter the transaction details.',
    '*153*3#',
  );

  @override
  void initState() {
    super.initState();
    _targetController.addListener(_refreshPreview);
    _amountController.addListener(_refreshPreview);
    _refreshPreview();
  }

  @override
  void dispose() {
    _targetController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    setState(() {
      _result = _builder.build(
        method: _method,
        rawTarget: _targetController.text,
        rawAmount: _amountController.text,
      );
    });
  }

  void _selectMethod(ShortcodeMethod method) {
    setState(() {
      _method = method;
      _targetController.clear();
      _amountController.clear();
      _result = ShortcodeBuildResult.invalid(
        'Enter the transaction details.',
        method.baseCode,
      );
    });
  }

  Future<void> _pastePhone() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty) return;
    _targetController.text = _builder.normalizePhoneCandidate(text);
  }

  Future<void> _pickContact() async {
    try {
      final phone = await _phoneService.pickContactPhone();
      if (phone == null || phone.trim().isEmpty) return;
      _targetController.text = _builder.normalizePhoneCandidate(phone);
    } on PlatformException catch (error) {
      _showMessage(error.message ?? 'Could not pick a contact.');
    }
  }

  Future<void> _dial() async {
    if (!_result.isValid) {
      _showMessage(_result.error ?? 'Please complete the required fields.');
      return;
    }

    try {
      await _phoneService.dial(_result.code);
      _targetController.clear();
      _amountController.clear();
    } on PlatformException catch (error) {
      _showMessage(error.message ?? 'Could not open the phone dialer.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isAgentCode = _method.needsAgentCode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemUiOverlayStyle,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: ShortcodeHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              sliver: SliverList.list(
                children: [
                  ActionSelector(selected: _method, onChanged: _selectMethod),
                  const SizedBox(height: 18),
                  LabeledInput(
                    controller: _targetController,
                    label: _method.numberLabel,
                    hint: _method.numberHint,
                    keyboardType: TextInputType.phone,
                    inputFormatters: isAgentCode
                        ? [FilteringTextInputFormatter.digitsOnly]
                        : const [],
                    trailing: isAgentCode
                        ? null
                        : Wrap(
                            spacing: 4,
                            children: [
                              _TinyActionButton(
                                icon: Icons.content_paste_rounded,
                                onTap: _pastePhone,
                              ),
                              _TinyActionButton(
                                icon: Icons.contacts_rounded,
                                onTap: _pickContact,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 14),
                  LabeledInput(
                    controller: _amountController,
                    label: _method.amountLabel,
                    hint: 'e.g. 10',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 10),
                  AmountChips(
                    onSelected: (amount) => _amountController.text = amount,
                  ),
                  const SizedBox(height: 18),
                  PreviewCard(
                    code: _result.code,
                    isValid: _result.isValid,
                    onDial: _dial,
                  ),
                  const SizedBox(height: 16),
                  AboutFooter(
                    phoneService: _phoneService,
                    onError: _showMessage,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Zimbabwe · EcoCash agent shortcodes',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mutedInk, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyActionButton extends StatelessWidget {
  const _TinyActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.emerald, size: 18),
      ),
    );
  }
}
