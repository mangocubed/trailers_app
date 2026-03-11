import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'constants.dart';
import 'components/snackbar_alert.dart';
import 'config.dart';

class IdentityClient {
  static OAuth2Client get _oauth2Client {
    final authorizeUrl = Config.identityUrl.replace(path: '/oauth/authorize');
    final tokenUrl = Config.identityApiUrl.replace(path: '/oauth/token');
    final revokeUrl = Config.identityApiUrl.replace(path: '/oauth/revoke');
    final identityRedirectUrl = Config.identityRedirectUrl;

    final client = OAuth2Client(
      authorizeUrl: authorizeUrl.toString(),
      redirectUri: identityRedirectUrl.toString(),
      customUriScheme: identityRedirectUrl.scheme,
      tokenUrl: tokenUrl.toString(),
      refreshUrl: tokenUrl.toString(),
      revokeUrl: revokeUrl.toString(),
      credentialsLocation: CredentialsLocation.body,
    );

    return client;
  }

  static final _storage = FlutterSecureStorage();

  static Future<AccessTokenResponse?> _getAccessToken() async {
    final value = await _storage.read(key: keyAccessToken);

    if (value == null) {
      return null;
    }

    var accessToken = AccessTokenResponse.fromMap(jsonDecode(value));

    if (accessToken.accessToken == null) {
      return null;
    }

    if (accessToken.refreshNeeded() && accessToken.refreshToken != null) {
      accessToken = await _oauth2Client.refreshToken(accessToken.refreshToken!, clientId: Config.identityClientId);

      if (accessToken.accessToken == null) {
        return null;
      }

      await _saveAccessToken(accessToken);
    }

    return accessToken;
  }

  static Future<void> _saveAccessToken(AccessTokenResponse accessToken) async {
    await _storage.write(key: keyAccessToken, value: jsonEncode(accessToken.toMap()));
  }

  static Future<void> authorize(BuildContext context) async {
    try {
      final accessToken = await _oauth2Client.getTokenWithAuthCodeFlow(
        clientId: Config.identityClientId,
        enableState: false,
      );

      if (accessToken.accessToken == null) {
        if (context.mounted) {
          SnackBarAlert.show(context, 'Failed to authenticate user');
        }

        return;
      }

      await _saveAccessToken(accessToken);

      if (context.mounted) {
        SnackBarAlert.show(context, 'User authenticated successfully');
      }
    } catch (error) {
      if (context.mounted) {
        SnackBarAlert.show(context, 'Failed to authenticate user');
      }
    }
  }

  static Future<String?> getBearer() async {
    var accessToken = await _getAccessToken();

    if (accessToken == null) {
      return null;
    }

    return 'Bearer ${accessToken.accessToken}';
  }
}
