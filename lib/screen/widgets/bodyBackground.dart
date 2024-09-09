import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BodyBackground extends StatelessWidget {
  const BodyBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          'assets/images/balloonebackground.svg',
          width: 412,
          height: 900,
          fit: BoxFit.cover,
        ),
        child,
      ],
    );
  }
}
