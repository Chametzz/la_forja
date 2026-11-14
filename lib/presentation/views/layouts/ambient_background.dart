import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fondo "ambiental" con orbes suaves que se desvanecen a transparente,
/// estilo YouTube Music / Gemini.
///
/// - Usa solo [RadialGradient] (sin [ImageFilter.blur]) → barato de pintar.
/// - Todo se adapta al tamaño de pantalla.
/// - Toma los colores del [ColorScheme] del tema por defecto.
/// - Puede animarse con una deriva muy sutil y opcional.
///
/// Por defecto coloca **dos orbes anclados a las esquinas**:
///   - superior izquierda (`scheme.primary`)
///   - inferior derecha (`scheme.tertiary`)
///
/// Para personalizar solo los colores de esos dos orbes:
/// ```dart
/// AmbientBackground(
///   topLeftColor: Colors.purple,
///   bottomRightColor: Colors.blue,
///   child: ...,
/// )
/// ```
///
/// Para control total (posición, tamaño, opacidad, cantidad), pasá [orbs].
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.orbs,
    this.topLeftColor,
    this.bottomRightColor,
    this.baseColor,
    this.intensity = 1.0,
    this.animated = false,
    this.animationDuration = const Duration(seconds: 14),
    this.driftAmount = 0.05,
  });

  /// Contenido a mostrar encima de los orbes.
  final Widget child;

  /// Orbes personalizados. Si es `null`, se usan
  /// [AmbientBackground.defaultOrbs] aplicando [topLeftColor] /
  /// [bottomRightColor] si están presentes.
  final List<AmbientOrb>? orbs;

  /// Color del orbe de la esquina superior izquierda.
  /// Si es `null`, usa `ColorScheme.primary`.
  final Color? topLeftColor;

  /// Color del orbe de la esquina inferior derecha.
  /// Si es `null`, usa `ColorScheme.tertiary`.
  final Color? bottomRightColor;

  /// Color de fondo sólido debajo de los orbes.
  /// Por defecto, [ColorScheme.surface].
  final Color? baseColor;

  /// Multiplicador aplicado a la opacidad pico de cada orbe.
  /// `0.5` = muy sutil, `1.0` = normal, `1.4` = vibrante.
  final double intensity;

  /// Si los orbes derivan lentamente.
  final bool animated;

  /// Duración de un ciclo completo de deriva.
  final Duration animationDuration;

  /// Amplitud de la deriva, en unidades fraccionarias de pantalla.
  final double driftAmount;

  /// Set por defecto: dos orbes anclados a las esquinas opuestas.
  ///
  /// Con `position: Offset(-1, -1)` el **centro** del orbe queda justo
  /// en la esquina superior izquierda, así que la mitad del orbe
  /// "sangra" fuera de pantalla.
  static List<AmbientOrb> defaultOrbs(
    ColorScheme scheme, {
    Color? topLeftColor,
    Color? bottomRightColor,
  }) => [
    AmbientOrb(
      color: topLeftColor ?? scheme.primary,
      sizeFactor: 1.15,
      position: const Offset(-1.0, -1.0),
      opacity: 0.55,
    ),
    AmbientOrb(
      color: bottomRightColor ?? scheme.primary,
      sizeFactor: 1.25,
      position: const Offset(1.0, 1.0),
      opacity: 0.55,
    ),
  ];

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animated) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AmbientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animationDuration != oldWidget.animationDuration) {
      _controller.duration = widget.animationDuration;
      if (_controller.isAnimating) _controller.repeat(reverse: true);
    }
    if (widget.animated && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animated && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final orbs =
        widget.orbs ??
        AmbientBackground.defaultOrbs(
          scheme,
          topLeftColor: widget.topLeftColor,
          bottomRightColor: widget.bottomRightColor,
        );
    final baseColor = widget.baseColor ?? scheme.surface;

    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: baseColor)),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Stack(
                    children: [
                      for (var i = 0; i < orbs.length; i++)
                        _buildOrb(
                          orb: orbs[i],
                          index: i,
                          constraints: constraints,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildOrb({
    required AmbientOrb orb,
    required int index,
    required BoxConstraints constraints,
  }) {
    final screenW = constraints.maxWidth;
    final screenH = constraints.maxHeight;
    if (screenW == 0 || screenH == 0) return const SizedBox.shrink();

    final minSide = math.min(screenW, screenH);
    final size = minSide * orb.sizeFactor;

    // Deriva sutil, con fase distinta por orbe para que no vayan sincronizados.
    double driftX = 0;
    double driftY = 0;
    if (widget.animated) {
      final t = _controller.value * 2 * math.pi;
      final phase = index * math.pi / 3;
      driftX = math.sin(t + phase) * widget.driftAmount;
      driftY = math.cos(t + phase) * widget.driftAmount;
    }

    // `position` se interpreta como un Offset en el rango [-1, 1] donde:
    //   (-1, -1) → esquina superior izquierda (orbe "sangrando")
    //   ( 1,  1) → esquina inferior derecha
    //   ( 0,  0) → centro de pantalla
    // Valores fuera de [-1, 1] lo empujan todavía más fuera de pantalla.
    final cx = (orb.position.dx + driftX + 1) / 2 * screenW;
    final cy = (orb.position.dy + driftY + 1) / 2 * screenH;

    return Positioned(
      left: cx - size / 2,
      top: cy - size / 2,
      width: size,
      height: size,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                orb.color.withValues(
                  alpha: (orb.opacity * widget.intensity).clamp(0.0, 1.0),
                ),
                orb.color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Configuración de un orbe para [AmbientBackground].
@immutable
class AmbientOrb {
  const AmbientOrb({
    required this.color,
    this.sizeFactor = 1.0,
    this.position = Offset.zero,
    this.opacity = 0.5,
  });

  /// Color base. El gradiente va de este color a transparente.
  final Color color;

  /// Diámetro del orbe como fracción del lado más corto de la pantalla.
  /// Valores típicos: 0.8 – 1.5.
  final double sizeFactor;

  /// Centro del orbe en un grid [-1, 1] donde:
  ///   - `Offset(-1, -1)` → esquina superior izquierda (orbe "sangrando")
  ///   - `Offset( 1,  1)` → esquina inferior derecha
  ///   - `Offset.zero`    → centro de pantalla
  /// Valores fuera de [-1, 1] empujan el orbe todavía más fuera de pantalla.
  final Offset position;

  /// Opacidad pico en el centro del orbe (antes del `intensity` global).
  final double opacity;
}
