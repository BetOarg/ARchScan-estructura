import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logotipo oficial reutilizable de ARchScan.
class ArchScanLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const ArchScanLogo({
    super.key,
    this.size = 48,
    this.showWordmark = false,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = Semantics(
      image: true,
      label: 'ARchScan',
      child: SvgPicture.asset(
        'assets/images/archscan_logo.svg',
        width: size,
        height: size,
      ),
    );

    if (!showWordmark) {
      return symbol;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        symbol,
        SizedBox(width: size * 0.2),
        Text(
          'ARchScan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
