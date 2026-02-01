import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:trailers/session.dart';

import 'config.dart';
import 'constants.dart';

extension GraphQLClientExt on GraphQLClient {
  static GraphQLClient setup() => GraphQLClient(
    link: AuthLink(
      getToken: () async => 'Bearer ${await Session.getToken()}',
    ).concat(HttpLink(Config.graphqlServerUrl, defaultHeaders: {headerXApiToken: Config.apiToken})),
    cache: GraphQLCache(store: HiveStore()),
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.networkOnly),
      mutate: Policies(fetch: FetchPolicy.networkOnly),
      watchQuery: Policies(fetch: FetchPolicy.cacheAndNetwork),
    ),
  );
}

extension BuildContextExt on BuildContext {
  ValueNotifier<GraphQLClient> get graphQLClient => GraphQLProvider.of(this);
}
