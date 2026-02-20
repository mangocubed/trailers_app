import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2_client/access_token_response.dart';

import 'constants.dart';

class AccessToken {
  AccessToken({required this.code, required this.refreshCode, required this.expiresAt});

  final String code;
  final String refreshCode;
  final DateTime expiresAt;

  static final _storage = FlutterSecureStorage();

  static Future<void> delete() {
    return _storage.delete(key: keyAccessToken);
  }

  static Future<String?> getBearer() async {
    final accessToken = await read();

    if (accessToken == null) {
      return null;
    }

    return 'Bearer ${accessToken.code}';
  }

  static Future<AccessToken?> read() async {
    final value = await _storage.read(key: keyAccessToken);

    if (value == null) {
      return null;
    }

    final Map<String, dynamic> jsonObject = jsonDecode(value);

    return AccessToken(
      code: jsonObject['code']!,
      refreshCode: jsonObject['refreshCode']!,
      expiresAt: DateTime.parse(jsonObject['expiresAt']!),
    );
  }

  static Future<void> write(AccessTokenResponse value) {
    final jsonObject = {
      'code': value.accessToken!,
      'refreshCode': value.refreshToken!,
      'expiresAt': value.expirationDate!.toIso8601String(),
    };

    return _storage.write(key: keyAccessToken, value: jsonEncode(jsonObject));
  }
}
