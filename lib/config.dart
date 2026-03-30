import 'package:flutter/foundation.dart';

class Config {
  static final _adUrl = const String.fromEnvironment('AD_URL');

  static final Uri? adUrl = _adUrl.isNotEmpty ? Uri.parse(_adUrl) : null;

  static final adSize = const String.fromEnvironment('AD_SIZE').split('x').map((s) => double.parse(s)).toList();

  static final Uri identityApiUrl = Uri.parse(
    const String.fromEnvironment('IDENTITY_API_URL', defaultValue: 'http://127.0.0.1:8005'),
  );

  static final String identityClientId = const String.fromEnvironment('IDENTITY_CLIENT_ID');

  static final Uri identityRedirectUrl = Uri.parse(
    const String.fromEnvironment(
      'IDENTITY_REDIRECT_URL',
      defaultValue: kDebugMode ? 'app.mango3.trailers.debug://oauth' : 'app.mango3.trailers://oauth',
    ),
  );

  static final Uri identityUrl = Uri.parse(
    const String.fromEnvironment('IDENTITY_URL', defaultValue: 'http://127.0.0.1:8000'),
  );

  static final Uri trailersApiUrl = Uri.parse(
    const String.fromEnvironment('TRAILERS_API_URL', defaultValue: 'http://127.0.0.1:8015'),
  );
}
