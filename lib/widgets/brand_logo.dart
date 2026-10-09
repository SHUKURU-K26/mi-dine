import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final logo = SizedBox(
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: ClipRect(
          child: Align(
            alignment: Alignment.center,
            widthFactor: 0.34,
            heightFactor: 0.64,
            child: Image.asset('assets/icon/logo.jpg', width: 1024),
          ),
        ),
      ),
    );

    if (!dark) return logo;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: logo,
    );
  }
}