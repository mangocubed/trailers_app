import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'access_token.dart';
import 'config.dart';

extension GraphQLClientExt on GraphQLClient {
  static GraphQLClient setup() => GraphQLClient(
    link: AuthLink(
      getToken: () => AccessToken.getBearer(),
    ).concat(HttpLink(Config.trailersApiUrl.replace(path: '/graphql').toString())),
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
