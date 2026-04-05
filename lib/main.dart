import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'constants.dart';
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
        title: 'Filmstrip',
        scrollBehavior: const MobileLikeScrollBehavior(),
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: colorPrimary, brightness: Brightness.dark),
          useMaterial3: true,
          textTheme: TextTheme(
            bodyLarge: GoogleFonts.amiko(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white),
            bodyMedium: GoogleFonts.amiko(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
            bodySmall: GoogleFonts.amiko(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(20),
              textStyle: GoogleFonts.amiko(fontSize: 14, fontWeight: FontWeight.w700),
              backgroundColor: colorPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              textStyle: GoogleFonts.amiko(fontSize: 14, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(20),
              textStyle: GoogleFonts.amiko(fontSize: 14, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
            labelPadding: const EdgeInsets.all(4),
            side: BorderSide(color: colorChip),
            brightness: Brightness.dark,
            selectedColor: colorChip,
            backgroundColor: Colors.transparent,
            checkmarkColor: Colors.black,
            deleteIconColor: Colors.black,
            labelStyle: GoogleFonts.amiko(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: WidgetStateColor.resolveWith((state) {
                return state.contains(WidgetState.selected) ? Colors.black : colorChip;
              }),
            ),
          ),
        ),
        routerConfig: GoRouterExt.setup(),
      ),
    );
  }
}
