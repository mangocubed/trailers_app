import 'package:flutter/material.dart';

class SensitivePhysics extends BouncingScrollPhysics {
  const SensitivePhysics({super.parent});

  @override
  SensitivePhysics applyTo(ScrollPhysics? ancestor) {
    return SensitivePhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(mass: 0.25, stiffness: 1000.0, ratio: 1.1);
}

class SensitivePageView extends StatelessWidget {
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

  int get _currentPage => controller.page?.round() ?? 0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (ScrollEndNotification notification) {
        onPageChanged(_currentPage);

        return true;
      },
      child: PageView.builder(
        controller: controller,
        allowImplicitScrolling: true,
        scrollDirection: Axis.vertical,
        physics: SensitivePhysics(),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
