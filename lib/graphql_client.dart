import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'identity_client.dart';
import 'config.dart';

extension GraphQLClientExt on GraphQLClient {
  static GraphQLClient setup() => GraphQLClient(
    link: AuthLink(getToken: IdentityClient.getBearer)
        .concat(
          ErrorLink(
            onException: (request, forward, exception) {
              if (exception is ServerException && exception.statusCode == 401) {
                IdentityClient.disconnect();

                throw exception;
              }

              return forward(request);
            },
          ),
        )
        .concat(HttpLink(Config.trailersApiUrl.replace(path: '/graphql').toString())),
    cache: GraphQLCache(store: HiveStore()),
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.networkOnly),
      mutate: Policies(fetch: FetchPolicy.networkOnly),
      watchQuery: Policies(fetch: FetchPolicy.cacheAndNetwork),
    ),
    queryRequestTimeout: const Duration(minutes: 1),
  );
}

extension BuildContextExt on BuildContext {
  ValueNotifier<GraphQLClient> get graphQLClient => GraphQLProvider.of(this);
}
