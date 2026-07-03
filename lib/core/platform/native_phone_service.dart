import 'package:flutter/services.dart';

class NativePhoneService {
  static const _channel = MethodChannel('shortcode.fintraqr.com/phone');

  const NativePhoneService();

  Future<void> dial(String code) async {
    await _channel.invokeMethod<void>('dial', {'code': code});
  }

  Future<String?> pickContactPhone() {
    return _channel.invokeMethod<String>('pickContactPhone');
  }

  Future<void> shareText(String text) async {
    await _channel.invokeMethod<void>('shareText', {'text': text});
  }

  Future<void> openUrl(String url) async {
    await _channel.invokeMethod<void>('openUrl', {'url': url});
  }
}
