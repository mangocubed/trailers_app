class Config {
  static final Uri identityApiUrl = Uri.parse(
    const String.fromEnvironment('IDENTITY_API_URL', defaultValue: 'http://127.0.0.1:8005'),
  );

  static final String identityClientId = const String.fromEnvironment('IDENTITY_CLIENT_ID', defaultValue: '');

  static final Uri identityUrl = Uri.parse(
    const String.fromEnvironment('IDENTITY_URL', defaultValue: 'http://127.0.0.1:8000'),
  );

  static final String trailersApiToken = const String.fromEnvironment('TRAILERS_API_TOKEN', defaultValue: 'trailers');

  static final Uri trailersApiUrl = Uri.parse(
    const String.fromEnvironment('TRAILERS_API_URL', defaultValue: 'http://127.0.0.1:8015'),
  );
}
