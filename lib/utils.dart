import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'graphql/fragments/title_fragment.graphql.dart';
import 'graphql/mutations/create_user_title_tie.graphql.dart';
import 'graphql/schema.graphql.dart';
import 'graphql_client.dart';
import 'identity_client.dart';

extension StringExt on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }

    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

Future<void> createUserTitleTie(BuildContext context, Fragment$TitleFragment title) async {
  if (title.currentUserTie == null && await IdentityClient.isAuthorized() && context.mounted) {
    await context.graphQLClient.value.mutate$CreateUserTitleTie(
      Options$Mutation$CreateUserTitleTie(
        variables: Variables$Mutation$CreateUserTitleTie(input: Input$UserTitleTieInputObject(titleId: title.id)),
      ),
    );
  }
}

Map<String, dynamic> getTitlesFilterQueryParams({
  Enum$TitleMediaType? mediaType,
  List<String>? genreIds,
  List<String>? watchProviderIds,
  String? countryCode,
}) {
  final Map<String, String> queryParams = {};

  if (mediaType != null) {
    queryParams[keyMediaType] = mediaType.toJson();
  }

  if (genreIds != null && genreIds.isNotEmpty) {
    queryParams[keyGenreIds] = genreIds.join(',');
  }

  if (watchProviderIds != null && watchProviderIds.isNotEmpty) {
    queryParams[keyWatchProviderIds] = watchProviderIds.join(',');
  }

  if (countryCode != null && countryCode.isNotEmpty) {
    queryParams[keyCountryCode] = countryCode;
  }

  return queryParams;
}
