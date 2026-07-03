import 'shortcode_method.dart';

class ShortcodeBuildResult {
  const ShortcodeBuildResult.valid(this.code)
    : error = null,
      fallbackCode = null;
  const ShortcodeBuildResult.invalid(this.error, String fallbackCode)
    : code = fallbackCode,
      fallbackCode = fallbackCode;

  final String code;
  final String? error;
  final String? fallbackCode;

  bool get isValid => error == null;
}

class ShortcodeBuilder {
  const ShortcodeBuilder();

  ShortcodeBuildResult build({
    required ShortcodeMethod method,
    required String rawTarget,
    required String rawAmount,
  }) {
    final target = method.needsAgentCode
        ? _sanitizeAgentCode(rawTarget)
        : _normalizeZimNumber(rawTarget);

    if (method.needsAgentCode) {
      if (!_isValidAgentCode(target)) {
        return ShortcodeBuildResult.invalid(
          'Enter a valid agent code with 4 to 6 digits.',
          method.baseCode,
        );
      }
    } else if (!_isValidZimMsisdn(target)) {
      return ShortcodeBuildResult.invalid(
        'Enter a valid Zimbabwe number, for example 0772123456.',
        method.baseCode,
      );
    }

    final amount = _sanitizeIntegerAmount(rawAmount);
    if (amount == null) {
      return ShortcodeBuildResult.invalid(
        'Enter a whole USD amount with no cents.',
        method.baseCode,
      );
    }

    final dialTarget = method.stripLeadingZero
        ? target.replaceFirst(RegExp('^0'), '')
        : target;

    return ShortcodeBuildResult.valid(method.build(dialTarget, amount));
  }

  String normalizePhoneCandidate(String input) => _normalizeZimNumber(input);

  String _normalizeZimNumber(String input) {
    var number = input.replaceAll(RegExp(r'[^0-9+]'), '');
    if (number.isEmpty) return '';
    if (number.startsWith('+263')) return '0${number.substring(4)}';
    if (number.startsWith('263')) return '0${number.substring(3)}';
    if (RegExp(r'^7\d{8}$').hasMatch(number)) return '0$number';
    return number;
  }

  String _sanitizeAgentCode(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }

  bool _isValidZimMsisdn(String number) {
    return RegExp(r'^07[0-9]{8}$').hasMatch(number);
  }

  bool _isValidAgentCode(String code) {
    return RegExp(r'^\d{4,6}$').hasMatch(code);
  }

  String? _sanitizeIntegerAmount(String input) {
    var value = input.trim().replaceAll(RegExp(r'\s'), '');
    if (value.contains('.') || value.contains(',')) return null;
    if (!RegExp(r'^\d+$').hasMatch(value)) return null;
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) return null;
    return parsed.toString();
  }
}
