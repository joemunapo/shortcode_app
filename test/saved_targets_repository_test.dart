import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortcode/features/shortcode/data/saved_targets_repository.dart';
import 'package:shortcode/features/shortcode/domain/saved_target.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SavedTargetsRepository repo;
  var tick = 0;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tick = 0;
    repo = SavedTargetsRepository(
      clock: () => DateTime.fromMillisecondsSinceEpoch(++tick * 1000),
    );
  });

  test('recordUse creates an unnamed recent and bumps use count', () async {
    var targets = await repo.recordUse(TargetType.phone, '0772123456');
    expect(targets, hasLength(1));
    expect(targets.single.isNamed, isFalse);
    expect(targets.single.useCount, 1);

    targets = await repo.recordUse(TargetType.phone, '0772123456');
    expect(targets, hasLength(1));
    expect(targets.single.useCount, 2);
  });

  test('recents are capped and the oldest is evicted', () async {
    for (var i = 0; i < SavedTargetsRepository.maxRecents + 1; i++) {
      await repo.recordUse(TargetType.phone, '077212345$i');
    }
    final targets = await repo.load(TargetType.phone);
    expect(targets, hasLength(SavedTargetsRepository.maxRecents));
    expect(targets.any((t) => t.value == '0772123450'), isFalse);
    expect(targets.first.value, '0772123455');
  });

  test('saveNamed upserts a recent in place and keeps its use count', () async {
    await repo.recordUse(TargetType.phone, '0772123456');
    final targets = await repo.saveNamed(
      TargetType.phone,
      '0772123456',
      name: '  Tinotenda Moyo  ',
      nickname: '  ',
    );
    expect(targets, hasLength(1));
    final entry = targets.single;
    expect(entry.name, 'Tinotenda Moyo');
    expect(entry.nickname, isNull);
    expect(entry.useCount, 1);
  });

  test('saveNamed stores an optional nickname', () async {
    final targets = await repo.saveNamed(
      TargetType.phone,
      '0772123456',
      name: 'Tinotenda Moyo',
      nickname: 'Mai Tino',
    );
    expect(targets.single.nickname, 'Mai Tino');
  });

  test('named entries are ordered before recents', () async {
    await repo.recordUse(TargetType.phone, '0713555210');
    await repo.saveNamed(TargetType.phone, '0772123456', name: 'Tino');
    await repo.recordUse(TargetType.phone, '0779000000');

    final targets = await repo.load(TargetType.phone);
    expect(targets.map((t) => t.value).toList(), [
      '0772123456',
      '0779000000',
      '0713555210',
    ]);
  });

  test('remove deletes an entry', () async {
    await repo.saveNamed(TargetType.phone, '0772123456', name: 'Tino');
    final targets = await repo.remove(TargetType.phone, '0772123456');
    expect(targets, isEmpty);
  });

  test('phone and agent code lists are independent', () async {
    await repo.saveNamed(TargetType.agentCode, '12345', name: 'Shop kiosk');
    expect(await repo.load(TargetType.phone), isEmpty);
    expect((await repo.load(TargetType.agentCode)).single.value, '12345');
  });

  test('load survives corrupt stored data', () async {
    SharedPreferences.setMockInitialValues({'saved_targets_phone': 'not json'});
    expect(await repo.load(TargetType.phone), isEmpty);
  });

  test('formatTargetValue groups phone numbers only', () {
    expect(formatTargetValue(TargetType.phone, '0772123456'), '0772 123 456');
    expect(formatTargetValue(TargetType.agentCode, '12345'), '12345');
    expect(formatTargetValue(TargetType.phone, '123'), '123');
  });
}
