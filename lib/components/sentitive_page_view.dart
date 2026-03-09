import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final Widget Function(BuildContext, int) itemBuilder;
  final int? itemCount;
  final void Function(int) onPageChanged;

  @override
  State<SensitivePageView> createState() => _SensitivePageViewState();
}

class _SensitivePageViewState extends State<SensitivePageView> {
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
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKeyDown);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKeyDown);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (ScrollEndNotification notification) {
        widget.onPageChanged(_currentPage);

        return true;
      },
      child: PageView.builder(
        controller: widget.controller,
        allowImplicitScrolling: true,
        scrollDirection: Axis.vertical,
        physics: SensitivePhysics(),
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder,
      ),
    );
  }
}
