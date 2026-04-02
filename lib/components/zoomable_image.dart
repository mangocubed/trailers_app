import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';

class ZoomableImage extends StatelessWidget {
  const ZoomableImage({super.key, required this.url, this.width, this.height, this.fit});

  final Uri? url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return url != null
        ? InkWell(
            onTap: () {
              showDialog(
                context: context,
                fullscreenDialog: true,
                builder: (context) {
                  return Dialog.fullscreen(
                    backgroundColor: colorTranslucent,
                    child: GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: Stack(
                        alignment: AlignmentGeometry.center,
                        children: [
                          Image.network(url!.toString(), width: screenSize.width - 24, height: screenSize.height - 24),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: CloseButton(
                              onPressed: () {
                                context.pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Image.network(url!.toString(), width: width, height: height, fit: fit),
          )
        : const SizedBox();
  }
}
