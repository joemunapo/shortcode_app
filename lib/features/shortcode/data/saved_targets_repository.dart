import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/saved_target.dart';

/// Persists saved and recent dial targets locally, one list per target type.
/// Named entries come first, then unnamed recents, both by most recent use.
class SavedTargetsRepository {
  SavedTargetsRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const maxRecents = 5;
  static const maxNamed = 15;

  final DateTime Function() _clock;

  String _key(TargetType type) => switch (type) {
    TargetType.phone => 'saved_targets_phone',
    TargetType.agentCode => 'saved_targets_agent',
  };

  Future<List<SavedTarget>> load(TargetType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(type));
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return _ordered([
        for (final entry in decoded)
          SavedTarget.fromJson(entry as Map<String, dynamic>),
      ]);
    } catch (_) {
      return const [];
    }
  }

  /// Records a successful dial, creating an unnamed recent when needed.
  Future<List<SavedTarget>> recordUse(TargetType type, String value) async {
    final targets = List.of(await load(type));
    final index = targets.indexWhere((t) => t.value == value);
    final now = _clock().millisecondsSinceEpoch;
    if (index >= 0) {
      targets[index] = targets[index].copyWith(
        lastUsedAt: now,
        useCount: targets[index].useCount + 1,
      );
    } else {
      targets.add(
        SavedTarget(value: value, name: '', lastUsedAt: now, useCount: 1),
      );
    }
    return _store(type, targets);
  }

  Future<List<SavedTarget>> saveNamed(
    TargetType type,
    String value, {
    required String name,
    String? nickname,
  }) async {
    final targets = List.of(await load(type));
    final index = targets.indexWhere((t) => t.value == value);
    final existing = index >= 0 ? targets[index] : null;
    final trimmedNickname = nickname?.trim();
    final entry = SavedTarget(
      value: value,
      name: name.trim(),
      nickname: (trimmedNickname == null || trimmedNickname.isEmpty)
          ? null
          : trimmedNickname,
      lastUsedAt: _clock().millisecondsSinceEpoch,
      useCount: existing?.useCount ?? 0,
    );
    if (existing != null) {
      targets[index] = entry;
    } else {
      targets.add(entry);
    }
    return _store(type, targets);
  }

  Future<List<SavedTarget>> remove(TargetType type, String value) async {
    final targets = (await load(type)).where((t) => t.value != value).toList();
    return _store(type, targets);
  }

  Future<List<SavedTarget>> _store(
    TargetType type,
    List<SavedTarget> targets,
  ) async {
    final result = _ordered(targets);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(type),
      jsonEncode([for (final t in result) t.toJson()]),
    );
    return result;
  }

  List<SavedTarget> _ordered(List<SavedTarget> targets) {
    List<SavedTarget> byRecency(bool named) {
      final list = targets.where((t) => t.isNamed == named).toList()
        ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
      return list;
    }

    return [
      ...byRecency(true).take(maxNamed),
      ...byRecency(false).take(maxRecents),
    ];
  }
}
