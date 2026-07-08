import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SaveTargetSheetResult {
  const SaveTargetSheetResult.saved({required this.name, this.nickname})
    : removed = false;

  const SaveTargetSheetResult.removed()
    : name = '',
      nickname = null,
      removed = true;

  final String name;
  final String? nickname;
  final bool removed;
}

Future<SaveTargetSheetResult?> showSaveTargetSheet(
  BuildContext context, {
  required String displayValue,
  required String typeLabel,
  String? initialName,
  String? initialNickname,
  bool canRemove = false,
}) {
  return showModalBottomSheet<SaveTargetSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _SaveTargetSheet(
        displayValue: displayValue,
        typeLabel: typeLabel,
        initialName: initialName,
        initialNickname: initialNickname,
        canRemove: canRemove,
      ),
    ),
  );
}

class _SaveTargetSheet extends StatefulWidget {
  const _SaveTargetSheet({
    required this.displayValue,
    required this.typeLabel,
    required this.initialName,
    required this.initialNickname,
    required this.canRemove,
  });

  final String displayValue;
  final String typeLabel;
  final String? initialName;
  final String? initialNickname;
  final bool canRemove;

  @override
  State<_SaveTargetSheet> createState() => _SaveTargetSheetState();
}

class _SaveTargetSheetState extends State<_SaveTargetSheet> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _nicknameController = TextEditingController(
    text: widget.initialNickname,
  );

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _save() {
    final nickname = _nicknameController.text.trim();
    Navigator.of(context).pop(
      SaveTargetSheetResult.saved(
        name: _nameController.text.trim(),
        nickname: nickname.isEmpty ? null : nickname,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nameController.text.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5DDD9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Save ${widget.displayValue}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              widget.typeLabel,
              style: const TextStyle(color: AppColors.mutedInk, fontSize: 12),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('EcoCash name'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Registered EcoCash name',
              ),
            ),
            const SizedBox(height: 12),
            const _FieldLabel('Nickname', optional: true),
            const SizedBox(height: 6),
            TextField(
              controller: _nicknameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => canSave ? _save() : null,
              decoration: const InputDecoration(
                hintText: 'What you call them',
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mutedInk,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: canSave ? _save : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            if (widget.canRemove)
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(const SaveTargetSheetResult.removed()),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Remove from saved'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        if (optional)
          const Text(
            '  ·  optional',
            style: TextStyle(color: AppColors.mutedInk, fontSize: 12),
          ),
      ],
    );
  }
}
