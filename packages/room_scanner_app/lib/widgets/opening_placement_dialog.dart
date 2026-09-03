import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:room_scanner_core/room_scanner_core.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/continuation_display_frame.dart';

class OpeningPlacement {
  final ARPoint location;
  final int wallIndex;
  final double width;
  final double openingHeightMeters;
  final double sillHeightMeters;
  const OpeningPlacement(this.location, this.wallIndex, this.width,
      this.openingHeightMeters, this.sillHeightMeters);
}

Future<OpeningPlacement?> showOpeningPlacementDialog({
  required BuildContext context,
  required RoomModel room,
  required MeasurementSystem system,
  required FeatureType type,
  ScanContinuationReference? reference,
  WallFeature? initialFeature,
  int? initialWallIndex,
  ARPoint? initialLocation,
  bool includeClosingWall = true,
}) async {
  final route = DialogRoute<OpeningPlacement>(
    context: context,
    builder: (_) => _OpeningPlacementDialog(room: room, system: system, type: type,
        reference: reference, initialFeature: initialFeature,
        initialWallIndex: initialWallIndex, initialLocation: initialLocation,
        includeClosingWall: includeClosingWall),
  );
  final result = await Navigator.of(context, rootNavigator: true).push(route);
  await route.completed;
  return result;
}

class _OpeningPlacementDialog extends StatefulWidget {
  final RoomModel room;
  final MeasurementSystem system;
  final FeatureType type;
  final WallFeature? initialFeature;
  final ScanContinuationReference? reference;
  final int? initialWallIndex;
  final ARPoint? initialLocation;
  final bool includeClosingWall;
  const _OpeningPlacementDialog({required this.room, required this.system, required this.type, this.reference, this.initialFeature,
    this.initialWallIndex, this.initialLocation, this.includeClosingWall = true});
  @override
  State<_OpeningPlacementDialog> createState() => _OpeningPlacementDialogState();
}

class _OpeningPlacementDialogState extends State<_OpeningPlacementDialog> {
  late final TextEditingController _width = TextEditingController(
    text: _inputValue(widget.initialFeature == null ? 0.8 :
        GeometryService.calculateDistance(widget.initialFeature!.start, widget.initialFeature!.end)),
  );
  late final TextEditingController _height = TextEditingController(
    text: _inputValue(widget.initialFeature?.openingHeightMeters ?? (widget.type == FeatureType.door ? 2.10 : 1.20)),
  );
  late final TextEditingController _sill = TextEditingController(
    text: _inputValue(widget.initialFeature?.sillHeightMeters ?? (widget.type == FeatureType.door ? 0 : 0.90)),
  );
  String _inputValue(double meters) =>
      (widget.system == MeasurementSystem.metric ? meters : meters / 0.0254)
          .toStringAsFixed(4);
  double _meters(TextEditingController controller) {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.')) ??
        double.nan;
    return widget.system == MeasurementSystem.metric
        ? value : MeasurementUnits.inchesToMeters(value);
  }
  bool get _validHeight => _meters(_height).isFinite && _meters(_height) > 0;
  bool get _validSill => _meters(_sill).isFinite && _meters(_sill) >= 0;
  int? _wall;
  double _fraction = 0.5;
  @override
  void initState() {
    super.initState();
    final count = widget.includeClosingWall && widget.room.points.length >= 3
        ? widget.room.points.length : widget.room.points.length - 1;
    final index = widget.initialWallIndex;
    if (index != null && index >= 0 && index < count) {
      _wall = index;
      final point = widget.initialLocation;
      if (point != null) {
        _fraction = PlanEditGeometry.fraction(point,
          widget.room.points[index], widget.room.points[(index + 1) % widget.room.points.length])
          .clamp(0.0, 1.0).toDouble();
      }
    }
  }
  double get widthMeters {
    final value = double.tryParse(_width.text.trim().replaceAll(',', '.')) ?? 0;
    return widget.system == MeasurementSystem.metric ? value : MeasurementUnits.inchesToMeters(value);
  }

  @override
  void dispose() {
    _width.dispose();
    _height.dispose();
    _sill.dispose();
    super.dispose();
  }

  OpeningPlacement? get placement {
    final index = _wall;
    if (index == null || !_validHeight || !_validSill) return null;
    final a = widget.room.points[index];
    final b = widget.room.points[(index + 1) % widget.room.points.length];
    final length = math.sqrt(math.pow(b.x-a.x, 2) + math.pow(b.z-a.z, 2));
    final width = widthMeters;
    if (!width.isFinite || width < 0.2 || width > length) return null;
    return OpeningPlacement(ARPoint(
      x: a.x + (b.x-a.x)*_fraction, y: a.y, z: a.z + (b.z-a.z)*_fraction,
    ), index, width, _meters(_height),
        widget.type == FeatureType.door ? 0 : _meters(_sill));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final frame = ContinuationDisplayFrame(widget.reference);
    final points = widget.room.points.map(frame.toDisplay).toList();
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.placeOpeningByTouch),
      content: SizedBox(
        width: 420,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l10n.touchOpeningInstructions),
          const SizedBox(height: 12),
          // AlertDialog queries intrinsic heights. Bound the preview before
          // LayoutBuilder so those queries never reach its layout callback.
          SizedBox(
            // CustomPaint has no child: keep its hit-test area full width.
            width: double.infinity,
            height: math.min(360.0,
                math.max(160.0, MediaQuery.sizeOf(context).width - 128)),
            child: LayoutBuilder(builder: (context, constraints) {
            final minX = points.map((p) => p.x).reduce(math.min);
            final minZ = points.map((p) => p.z).reduce(math.min);
            final maxX = points.map((p) => p.x).reduce(math.max);
            final maxZ = points.map((p) => p.z).reduce(math.max);
            final scale = math.min((constraints.maxWidth-40)/math.max(maxX-minX, 0.01),
                (constraints.maxHeight-40)/math.max(maxZ-minZ, 0.01));
            Offset project(ARPoint p) => Offset(20+(p.x-minX)*scale, 20+(p.z-minZ)*scale);
            final projected = points.map(project).toList();
            final wallCount = widget.includeClosingWall && projected.length >= 3 ? projected.length : projected.length-1;
            void select(Offset tap) {
              int? selected;
              var nearest = 28.0;
              var fraction = 0.0;
              for (var i=0; i<wallCount; i++) {
                final a = projected[i];
                final d = projected[(i+1)%projected.length]-a;
                if (d.distanceSquared < 0.001) continue;
                final t = (((tap-a).dx*d.dx+(tap-a).dy*d.dy)/d.distanceSquared).clamp(0.0, 1.0).toDouble();
                final distance = (tap-(a+d*t)).distance;
                if (distance < nearest) { selected=i; nearest=distance; fraction=t; }
              }
              if (selected != null) setState(() { _wall=selected; _fraction=fraction; });
            }
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => select(d.localPosition),
              // A short drag can finish as soon as it wins the gesture arena,
              // before any onPanUpdate is delivered. Apply that first position.
              onPanStart: (d) => select(d.localPosition),
              onPanUpdate: (d) => select(d.localPosition),
              child: CustomPaint(key: const ValueKey('opening-plan'), painter: _OpeningPlacementPainter(
                includeClosingWall: widget.includeClosingWall,
                points: projected, wall: _wall, fraction: _fraction,
                widthPixels: widthMeters*scale,
                existing: [for (final f in widget.room.features.where((f) => f.id != widget.initialFeature?.id))
                  [project(frame.toDisplay(f.start)), project(frame.toDisplay(f.end))]],
              )),
            );
          })),
          TextField(
            controller: _width,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l10n.openingWidth,
              suffixText: widget.system == MeasurementSystem.metric ? l10n.meters : l10n.inches),
          ),
          TextField(
            key: const ValueKey('opening-height'),
            controller: _height,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.openingHeight,
              errorText: _validHeight ? null : l10n.openingHeightPositive,
              suffixText: widget.system == MeasurementSystem.metric ? l10n.meters : l10n.inches,
            ),
          ),
          if (widget.type == FeatureType.window) TextField(
            key: const ValueKey('opening-sill'),
            controller: _sill,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.windowSillHeight,
              errorText: _validSill ? null : l10n.openingSillNonNegative,
              suffixText: widget.system == MeasurementSystem.metric ? l10n.meters : l10n.inches,
            ),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(onPressed: placement == null ? null : () => Navigator.pop(context, placement),
          child: Text(l10n.save)),
      ],
    );
  }
}

class _OpeningPlacementPainter extends CustomPainter {
  final bool includeClosingWall;
  final List<Offset> points;
  final List<List<Offset>> existing;
  final int? wall;
  final double fraction;
  final double widthPixels;
  const _OpeningPlacementPainter({required this.points, required this.existing,
    required this.wall, required this.fraction, required this.widthPixels,
    this.includeClosingWall = true});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color=Colors.blue..strokeWidth=4;
    final count = includeClosingWall && points.length >= 3 ? points.length : points.length-1;
    for(var i=0;i<count;i++) {
      canvas.drawLine(points[i], points[(i+1)%points.length], paint);
    }
    paint..color=Colors.purple..strokeWidth=6;
    for(final f in existing) {
      canvas.drawLine(f[0],f[1],paint);
    }
    final index=wall;
    if(index==null || !widthPixels.isFinite || widthPixels<=0) return;
    final a=points[index];
    final d=points[(index+1)%points.length]-a;
    final length=d.distance;
    if(length<=0) return;
    final width=math.min(widthPixels,length);
    final start=(fraction*length-width/2).clamp(0.0,length-width).toDouble();
    paint..color=widthPixels<=length ? Colors.orange : Colors.red..strokeWidth=10;
    canvas.drawLine(a+d*(start/length),a+d*((start+width)/length),paint);
  }
  @override
  bool shouldRepaint(covariant _OpeningPlacementPainter oldDelegate) => true;
}
