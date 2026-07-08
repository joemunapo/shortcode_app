import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/platform/native_phone_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/saved_targets_repository.dart';
import '../../domain/saved_target.dart';
import '../../domain/shortcode_builder.dart';
import '../../domain/shortcode_method.dart';
import '../widgets/action_selector.dart';
import '../widgets/amount_chips.dart';
import '../widgets/about_footer.dart';
import '../widgets/labeled_input.dart';
import '../widgets/preview_card.dart';
import '../widgets/save_target_sheet.dart';
import '../widgets/saved_target_chips.dart';
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
  final _savedRepo = SavedTargetsRepository();

  ShortcodeMethod _method = ShortcodeMethod.agentToAgent;
  List<SavedTarget> _targets = const [];
  ShortcodeBuildResult _result = const ShortcodeBuildResult.invalid(
    'Enter the transaction details.',
    '*153*3#',
  );

  TargetType get _targetType =>
      _method.needsAgentCode ? TargetType.agentCode : TargetType.phone;

  @override
  void initState() {
    super.initState();
    _targetController.addListener(_refreshPreview);
    _amountController.addListener(_refreshPreview);
    _refreshPreview();
    _loadTargets();
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
    _loadTargets();
  }

  Future<void> _loadTargets() async {
    final type = _targetType;
    final targets = await _savedRepo.load(type);
    if (!mounted || type != _targetType) return;
    setState(() => _targets = targets);
  }

  SavedTarget? _entryFor(String value) {
    for (final target in _targets) {
      if (target.value == value) return target;
    }
    return null;
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

    final type = _targetType;
    final target = _builder.normalizedValidTarget(
      method: _method,
      rawTarget: _targetController.text,
    );

    try {
      await _phoneService.dial(_result.code);
      _targetController.clear();
      _amountController.clear();
      if (target != null) {
        await _recordUse(type, target);
      }
    } on PlatformException catch (error) {
      _showMessage(error.message ?? 'Could not open the phone dialer.');
    }
  }

  Future<void> _recordUse(TargetType type, String value) async {
    final targets = await _savedRepo.recordUse(type, value);
    if (!mounted) return;
    if (type == _targetType) {
      setState(() => _targets = targets);
    }

    final isNamed = targets.any((t) => t.value == value && t.isNamed);
    if (isNamed) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${formatTargetValue(type, value)} added to recents'),
          action: SnackBarAction(
            label: 'Name it',
            onPressed: () => _openSaveSheet(type, value),
          ),
        ),
      );
  }

  Future<void> _openSaveSheet(
    TargetType type,
    String value, {
    SavedTarget? existing,
  }) async {
    existing ??= _entryFor(value);
    final result = await showSaveTargetSheet(
      context,
      displayValue: formatTargetValue(type, value),
      typeLabel: type == TargetType.agentCode
          ? '${_method.title} · agent code'
          : 'Phone number',
      initialName: existing?.name,
      initialNickname: existing?.nickname,
      canRemove: existing != null,
    );
    if (result == null || !mounted) return;

    final targets = result.removed
        ? await _savedRepo.remove(type, value)
        : await _savedRepo.saveNamed(
            type,
            value,
            name: result.name,
            nickname: result.nickname,
          );
    if (!mounted) return;
    if (type == _targetType) {
      setState(() => _targets = targets);
    }
    _showMessage(result.removed ? 'Removed.' : 'Saved.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isAgentCode = _method.needsAgentCode;
    final validTarget = _builder.normalizedValidTarget(
      method: _method,
      rawTarget: _targetController.text,
    );
    final matched = validTarget == null ? null : _entryFor(validTarget);
    final matchedNamed = (matched?.isNamed ?? false) ? matched : null;

    final trailingButtons = <Widget>[
      if (!isAgentCode) ...[
        _TinyActionButton(
          icon: Icons.content_paste_rounded,
          onTap: _pastePhone,
        ),
        _TinyActionButton(icon: Icons.contacts_rounded, onTap: _pickContact),
      ],
      if (validTarget != null)
        _TinyActionButton(
          icon: matchedNamed != null
              ? Icons.bookmark_rounded
              : Icons.bookmark_add_outlined,
          onTap: () =>
              _openSaveSheet(_targetType, validTarget, existing: matched),
        ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemUiOverlayStyle,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: ShortcodeHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ActionSelector(
                          selected: _method,
                          onChanged: _selectMethod,
                        ),
                        const SizedBox(height: 18),
                        LabeledInput(
                          controller: _targetController,
                          label: _method.numberLabel,
                          hint: _method.numberHint,
                          keyboardType: TextInputType.phone,
                          inputFormatters: isAgentCode
                              ? [FilteringTextInputFormatter.digitsOnly]
                              : const [],
                          trailing: trailingButtons.isEmpty
                              ? null
                              : Wrap(spacing: 4, children: trailingButtons),
                        ),
                        if (matchedNamed != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 15,
                                color: AppColors.emerald,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  matchedNamed.nickname == null
                                      ? matchedNamed.name
                                      : '${matchedNamed.name} · “${matchedNamed.nickname}”',
                                  style: const TextStyle(
                                    color: AppColors.mutedInk,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_targets.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SavedTargetChips(
                            type: _targetType,
                            entries: _targets,
                            onSelected: (entry) =>
                                _targetController.text = entry.value,
                            onLongPress: (entry) => _openSaveSheet(
                              _targetType,
                              entry.value,
                              existing: entry,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        LabeledInput(
                          controller: _amountController,
                          label: _method.amountLabel,
                          hint: 'e.g. 10',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        const SizedBox(height: 10),
                        AmountChips(
                          onSelected: (amount) =>
                              _amountController.text = amount,
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
                          style: TextStyle(
                            color: AppColors.mutedInk,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
