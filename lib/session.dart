import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'graphql/mutations/create_session.graphql.dart';
import 'graphql/queries/current_user.graphql.dart';
import 'graphql/schema.graphql.dart';
import 'graphql_client.dart';

class Session {
  static final Future<SharedPreferencesWithCache> _prefs = SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(allowList: <String>{keySessionToken}),
  );

  static Future<bool> create(BuildContext context, String usernameOrEmail, String password) async {
    final graphQLClient = context.graphQLClient.value;

    final result = await graphQLClient.mutate$CreateSession(
      Options$Mutation$CreateSession(
        variables: Variables$Mutation$CreateSession(
          input: Input$SessionInputObject(usernameOrEmail: usernameOrEmail, password: password),
        ),
      ),
    );

    final createSession = result.parsedData?.createSession;

    if (createSession != null) {
      final prefs = await _prefs;

      await prefs.setString(keySessionToken, createSession.token);

      return true;
    }

    return false;
  }

  static finish() async {
    final prefs = await _prefs;

    await prefs.remove(keySessionToken);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs;

    return prefs.getString(keySessionToken);
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();

    return token != null;
  }
}

extension SessionExt on BuildContext {
  Future<Query$CurrentUser$currentUser?> getCurrentUser() async {
    final result = await graphQLClient.value.query$CurrentUser();

    return result.parsedData?.currentUser;
  }
}
