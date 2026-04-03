import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trailers/constants.dart';

import '../router.dart';

class SensitivePhysics extends BouncingScrollPhysics {
  const SensitivePhysics({super.parent});

  @override
  SensitivePhysics applyTo(ScrollPhysics? ancestor) {
    return SensitivePhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(mass: 0.25, stiffness: 1000.0, ratio: 1.1);
}

class SensitivePageView extends StatefulWidget {
  const SensitivePageView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.itemCount,
    required this.onPageChanged,
  });

  final PageController controller;
  final Widget Function(BuildContext context, int index, bool isActive) itemBuilder;
  final int? itemCount;
  final void Function(int) onPageChanged;

  @override
  State<SensitivePageView> createState() => _SensitivePageViewState();
}

class _SensitivePageViewState extends State<SensitivePageView> with RouteAware {
  bool _isActive = false;

  int get _currentPage => widget.controller.page?.round() ?? 0;

  bool _onKeyDown(KeyEvent event) {
    if (event is KeyDownEvent) {
      final keyId = event.logicalKey.keyId;

      switch (keyId) {
        case 4294968068: // Up arrow
          widget.controller.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          break;
        case 4294968065: // Down arrow
          widget.controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          break;
        default:
          break;
      }
    }

    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentRoute = ModalRoute.of(context);

    if (currentRoute != null) {
      routeObserver.subscribe(this, currentRoute);
    }
  }

  @override
  void didPushNext() {
    setState(() {
      _isActive = false;
    });
  }

  @override
  void didPopNext() {
    setState(() {
      _isActive = true;
    });
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    _isActive = ModalRoute.of(context)?.isCurrent == true;
  }

  @override
  void initState() {
    super.initState();
    _isActive = true;
    ServicesBinding.instance.keyboard.addHandler(_onKeyDown);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKeyDown);
    _isActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = min(size.width, size.height) < 600;

    return NotificationListener<ScrollEndNotification>(
      onNotification: (ScrollEndNotification notification) {
        widget.onPageChanged(_currentPage);

        return true;
      },
      child: Stack(
        children: [
          PageView.builder(
            controller: widget.controller,
            allowImplicitScrolling: true,
            scrollDirection: Axis.vertical,
            physics: SensitivePhysics(),
            itemCount: widget.itemCount,
            itemBuilder: (context, index) => widget.itemBuilder(context, index, _isActive && _currentPage == index),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Visibility(
              visible: !isMobile,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Container(
                  decoration: BoxDecoration(color: colorTranslucent, borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_upward_rounded),
                        disabledColor: Colors.grey,
                        color: Colors.white,
                        tooltip: 'Previous',
                        onPressed: widget.controller.positions.isNotEmpty && (widget.controller.page ?? 0) > 0
                            ? () {
                                widget.controller.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward_rounded),
                        color: Colors.white,
                        tooltip: 'Next',
                        onPressed: () {
                          widget.controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
