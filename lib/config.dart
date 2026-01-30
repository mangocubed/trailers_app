class Config {
  static get apiToken => const String.fromEnvironment('API_TOKEN', defaultValue: 'trailers');

  static get graphqlServerUrl =>
      const String.fromEnvironment('GRAPHQL_SERVER_URL', defaultValue: 'http://127.0.0.1:8000/graphql');
}
