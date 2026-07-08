enum TargetType { phone, agentCode }

class SavedTarget {
  const SavedTarget({
    required this.value,
    required this.name,
    this.nickname,
    required this.lastUsedAt,
    required this.useCount,
  });

  factory SavedTarget.fromJson(Map<String, dynamic> json) {
    return SavedTarget(
      value: json['value'] as String,
      name: (json['name'] as String?) ?? '',
      nickname: json['nickname'] as String?,
      lastUsedAt: (json['lastUsedAt'] as num?)?.toInt() ?? 0,
      useCount: (json['useCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// The normalized dial target, e.g. `0772123456` or an agent code.
  final String value;

  /// The registered EcoCash name. Empty for auto-captured recents.
  final String name;

  /// Optional nickname the user knows the person by.
  final String? nickname;

  final int lastUsedAt;
  final int useCount;

  bool get isNamed => name.isNotEmpty;

  SavedTarget copyWith({
    String? name,
    String? nickname,
    int? lastUsedAt,
    int? useCount,
  }) {
    return SavedTarget(
      value: value,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      useCount: useCount ?? this.useCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'name': name,
      if (nickname != null) 'nickname': nickname,
      'lastUsedAt': lastUsedAt,
      'useCount': useCount,
    };
  }
}

String formatTargetValue(TargetType type, String value) {
  if (type != TargetType.phone || value.length != 10) return value;
  return '${value.substring(0, 4)} ${value.substring(4, 7)} ${value.substring(7)}';
}
