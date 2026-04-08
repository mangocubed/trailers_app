import 'package:flutter/foundation.dart';

class Config {
  static final _adUrl = const String.fromEnvironment('AD_URL', defaultValue: '');

  static final adSize = const String.fromEnvironment(
    'AD_SIZE',
    defaultValue: '300x250',
  ).split('x').map((s) => double.parse(s)).toList();

  static final Uri? adUrl = _adUrl.isNotEmpty ? Uri.parse(_adUrl) : null;

  static bool get hasAds => adUrl != null && adSize.length == 2;

  static final Uri identityApiUrl = Uri.parse(
    const String.fromEnvironment('IDENTITY_API_URL', defaultValue: 'https://api.id.mango3.app/'),
  );

  static final String identityClientId = const String.fromEnvironment('IDENTITY_CLIENT_ID');

  static final String identityClientToken = const String.fromEnvironment('IDENTITY_CLIENT_TOKEN');

  static final Uri identityRedirectUrl = Uri.parse(
    const String.fromEnvironment(
      'IDENTITY_REDIRECT_URL',
      defaultValue: kDebugMode ? 'app.mango3.trailers.debug://oauth' : 'app.mango3.trailers://oauth',
    ),
  );

  static final Uri identityUrl = Uri.parse(
    const String.fromEnvironment('IDENTITY_URL', defaultValue: 'https://id.mango3.app/'),
  );

  static final Duration searchDebounce = Duration(
    milliseconds: int.parse(const String.fromEnvironment('SEARCH_DEBOUNCE', defaultValue: '500')),
  );

  static final Uri trailersApiUrl = Uri.parse(
    const String.fromEnvironment('TRAILERS_API_URL', defaultValue: 'https://api.trailers.mango3.app/'),
  );

  static final Uri trailersUrl = Uri.parse(
    const String.fromEnvironment('TRAILERS_URL', defaultValue: 'https://filmstrip.mango3.app/'),
  );
}
