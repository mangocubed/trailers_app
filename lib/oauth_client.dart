import 'package:flutter/material.dart';
import 'package:oauth2_client/oauth2_client.dart';

import 'access_token.dart';
import 'components/snackbar_alert.dart';
import 'config.dart';

extension OAuthClientExt on OAuth2Client {
  static OAuth2Client get instance {
    final authorizeUrl = Config.identityUrl.replace(path: '/oauth/authorize');
    final tokenUrl = Config.identityApiUrl.replace(path: '/oauth/token');
    final revokeUrl = Config.identityApiUrl.replace(path: '/oauth/revoke');

    return OAuth2Client(
      authorizeUrl: authorizeUrl.toString(),
      redirectUri: Config.identityRedirectUrl.toString(),
      customUriScheme: 'app.mango3.trailers',
      tokenUrl: tokenUrl.toString(),
      refreshUrl: tokenUrl.toString(),
      revokeUrl: revokeUrl.toString(),
      credentialsLocation: CredentialsLocation.body,
    );
  }

  static Future<void> authorize(BuildContext context) async {
    try {
      final response = await instance.getTokenWithAuthCodeFlow(clientId: Config.identityClientId, enableState: false);

      await AccessToken.write(response);

      if (context.mounted) {
        SnackBarAlert.show(context, 'User authenticated successfully');
      }
    } catch (error) {
      if (context.mounted) {
        SnackBarAlert.show(context, 'Failed to authenticate user');
      }
    }
  }
}
