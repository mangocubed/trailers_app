import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql_client.dart';
import 'router.dart';

void main() async {
  await initHiveForFlutter();

  final graphQLClient = GraphQLClientExt.setup();

  runApp(App(graphQLClient: graphQLClient));
}

class MobileLikeScrollBehavior extends MaterialScrollBehavior {
  const MobileLikeScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class App extends StatelessWidget {
  const App({super.key, required this.graphQLClient});

  final GraphQLClient graphQLClient;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: ValueNotifier(graphQLClient),
      child: MaterialApp.router(
        title: 'Trailers',
        scrollBehavior: const MobileLikeScrollBehavior(),
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: GoogleFonts.amikoTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              side: const BorderSide(color: Colors.deepPurple),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        routerConfig: GoRouterExt.setup(),
      ),
    );
  }
}
