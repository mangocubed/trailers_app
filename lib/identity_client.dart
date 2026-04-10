import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' show closeCustomTabs;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:restart_app/restart_app.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'components/snackbar_alert.dart';
import 'config.dart';

class IdentityClient {
  static AccessTokenResponse? _accessToken;
  static final ValueNotifier<bool> _hasAccessToken = ValueNotifier(false);

  static final OAuth2Client _oauth2Client = OAuth2Client(
    authorizeUrl: Config.identityUrl.replace(path: '/oauth/authorize').toString(),
    redirectUri: Config.identityRedirectUrl.toString(),
    customUriScheme: Config.identityRedirectUrl.scheme,
    tokenUrl: Config.identityApiUrl.replace(path: '/oauth/token').toString(),
    refreshUrl: Config.identityApiUrl.replace(path: '/oauth/token').toString(),
    revokeUrl: Config.identityApiUrl.replace(path: '/oauth/revoke').toString(),
    credentialsLocation: CredentialsLocation.body,
  );

  static final _storage = FlutterSecureStorage();

  static Future<AccessTokenResponse?> _decodeAccessToken(String value) async {
    var accessToken = AccessTokenResponse.fromMap(jsonDecode(value));

    if (accessToken.accessToken == null) {
      await _deleteAccessToken();

      return null;
    }

    if (accessToken.refreshNeeded() && accessToken.refreshToken != null) {
      accessToken = await _oauth2Client.refreshToken(accessToken.refreshToken!, clientId: Config.identityClientId);

      if (accessToken.accessToken == null) {
        await _deleteAccessToken();

        return null;
      }

      await _writeAccessToken(accessToken);
    }

    return accessToken;
  }

  static Future<AccessTokenResponse?> _readAccessToken() async {
    final value = await _storage.read(key: keyAccessToken);

    if (value == null) {
      return null;
    }

    return await _decodeAccessToken(value);
  }

  static Future<void> _deleteAccessToken() async {
    await _storage.delete(key: keyAccessToken);
  }

  static Future<void> _writeAccessToken(AccessTokenResponse accessToken) async {
    await _storage.write(key: keyAccessToken, value: jsonEncode(accessToken.toMap()));
  }

  static Future<void> init() async {
    _accessToken = await _readAccessToken();
    _hasAccessToken.value = _accessToken != null;

    _storage.registerListener(
      key: keyAccessToken,
      listener: (value) async {
        if (value == null) {
          _accessToken = null;
          _hasAccessToken.value = false;

          return;
        }

        _accessToken = await _decodeAccessToken(value);
        _hasAccessToken.value = _accessToken != null;
      },
    );
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

      await _writeAccessToken(accessToken);
      await closeCustomTabs();

      if (context.mounted) {
        SnackBarAlert.show(context, 'User authenticated successfully');
      }
    } catch (error) {
      if (context.mounted) {
        SnackBarAlert.show(context, 'Failed to authenticate user');
      }
    }
  }

  /// Checks if the app is authorized and restarts if not.
  static Future<void> checkAuthorization() async {
    // Restart the app if the access token has changed on another instance.
    if (_accessToken?.accessToken != (await _readAccessToken())?.accessToken) {
      await Restart.restartApp();
    }

    // Restart the app if the access token is not valid.
    if (!await isAuthorized() && hasAccessToken()) {
      await _deleteAccessToken();

      await Restart.restartApp();
    }
  }

  static String? getBearer() {
    final token = _accessToken?.accessToken ?? Config.identityClientToken;

    if (token.isEmpty) {
      return null;
    }

    return 'Bearer $token';
  }

  static Future<void> goToIdentity() async {
    if (await canLaunchUrl(Config.identityUrl)) {
      await launchUrl(Config.identityUrl, mode: LaunchMode.inAppBrowserView);
    }
  }

  static bool hasAccessToken() {
    return _hasAccessToken.value;
  }

  static Future<bool> isAuthorized() async {
    final response = await http.get(
      Config.identityApiUrl.replace(path: '/authorized'),
      headers: {'Authorization': getBearer() ?? ''},
    );

    return response.statusCode == 200;
  }

  static void withAuthentication(BuildContext context, FutureOr<void> Function(BuildContext context) callback) async {
    if (hasAccessToken()) {
      await callback(context);
    } else {
      await IdentityClient.authorize(context);
    }
  }

  static void addListener(void Function() listener) {
    _hasAccessToken.addListener(listener);
  }

  static void removeListener(void Function() listener) {
    _hasAccessToken.removeListener(listener);
  }
}
