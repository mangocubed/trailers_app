import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';

class ShowAdScreen extends StatelessWidget {
  const ShowAdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
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
                  shouldOverrideUrlLoading: (controller, navigation) {
                    launchUrl(navigation.request.url!, mode: LaunchMode.externalApplication);

                    return NavigationActionPolicy.CANCEL;
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Chip(label: Text('Advertisement')),
          ),
        ],
      ),
    );
  }
}
