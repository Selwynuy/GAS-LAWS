import 'package:flutter/material.dart';
import '../../../widgets/lungs_widget.dart';

/// Diver widget with bubbles, lungs inside.
class DiverWidget extends StatelessWidget {
  final double normalizedLungVolume;

  const DiverWidget({
    super.key,
    required this.normalizedLungVolume,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use available space, make diver much bigger - scale based on screen size
        final diverWidth = constraints.maxWidth * 1.2; // 120% - allow overflow
        final diverHeight = constraints.maxHeight * 1.3; // 130% - allow overflow
        
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Diver image - much larger, unconstrained
            Image.asset(
              'assets/Scuba_Diver.png',
              width: diverWidth,
              height: diverHeight,
              fit: BoxFit.contain,
            ),
            // Lungs positioned inside the diver's chest area - moved up and scaled
            Positioned(
              top: diverHeight * 0.15, // Moved up (was fixed 70px)
              child: SizedBox(
                width: diverWidth * 0.4, // Scale with diver size
                height: diverHeight * 0.25, // Scale with diver size
                child: LungsWidget(normalizedVolume: normalizedLungVolume),
              ),
            ),
          ],
        );
      },
    );
  }
}

