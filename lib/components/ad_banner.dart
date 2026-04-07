import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:trailers/constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!Config.hasAds) {
      return const SizedBox();
    }

    return SafeArea(
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          SizedBox(
            width: Config.adSize.first,
            height: Config.adSize.last,
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri.uri(Config.adUrl!)),
              initialSettings: InAppWebViewSettings(
                disableContextMenu: true,
                disableHorizontalScroll: true,
                disableVerticalScroll: true,
                horizontalScrollBarEnabled: false,
                javaScriptEnabled: true,
                supportZoom: false,
                thirdPartyCookiesEnabled: true,
                verticalScrollBarEnabled: false,
                overScrollMode: OverScrollMode.NEVER,
                allowsBackForwardNavigationGestures: false,
                useShouldOverrideUrlLoading: true,
              ),
              shouldOverrideUrlLoading: (controller, navigation) async {
                final url = navigation.request.url;

                if (url != null && (await canLaunchUrl(url))) {
                  launchUrl(url, mode: LaunchMode.externalApplication);
                }

                return NavigationActionPolicy.CANCEL;
              },
            ),
          ),
          compact
              ? Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorTranslucent,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(4)),
                    ),
                    padding: const EdgeInsets.all(1),
                    child: Text('Ad', style: GoogleFonts.amiko(fontSize: 10, color: Colors.white)),
                  ),
                )
              : Positioned(bottom: 12, left: 12, child: Chip(label: Text('Advertisement'))),
        ],
      ),
    );
  }
}
