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

  static Future<String?> getBearer() async {
    final accessToken = await _getAccessToken();
    final token = accessToken?.accessToken ?? Config.identityClientToken;

    if (token.isEmpty) {
      return null;
    }

    return 'Bearer $token';
  }

  static Future<void> goToIdentity() async {
    if (await canLaunchUrl(Config.identityUrl)) {
      await launchUrl(Config.identityUrl, mode: LaunchMode.inAppBrowserView);

      if (!await isAuthorized()) {
        IdentityClient.disconnect();
      }
    }
  }

  static Future<bool> hasAccessToken() async {
    return (await _getAccessToken()) != null;
  }

  static Future<bool> isAuthenticated() async {
    return await hasAccessToken() && await isAuthorized();
  }

  static Future<bool> isAuthorized() async {
    final response = await http.get(
      Config.identityApiUrl.replace(path: '/authorized'),
      headers: {'Authorization': await getBearer() ?? ''},
    );

    return response.statusCode == 200;
  }

  static Future<void> disconnect() async {
    if (await hasAccessToken()) {
      await _storage.delete(key: keyAccessToken);

      await Restart.restartApp();
    }
  }

  static void withAuthentication(BuildContext context, FutureOr<void> Function(BuildContext context) callback) async {
    final hasAccessToken = await IdentityClient.hasAccessToken();

    if (!context.mounted) {
      return;
    }

    if (hasAccessToken) {
      await callback(context);
    } else {
      await IdentityClient.authorize(context);
    }
  }
}
