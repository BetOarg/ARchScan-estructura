import 'package:flutter/material.dart';
import 'package:room_scanner_core/room_scanner_core.dart';
import '../l10n/generated/app_localizations.dart';

class PlanWallLengthDialog extends StatefulWidget {
  final String roomName;
  final int wallNumber;
  final double meters;
  final MeasurementSystem system;
  const PlanWallLengthDialog({
    super.key,
    required this.roomName,
    required this.wallNumber,
    required this.meters,
    required this.system,
  });
  @override
  State<PlanWallLengthDialog> createState() => _PlanWallLengthDialogState();
}

class _PlanWallLengthDialogState extends State<PlanWallLengthDialog> {
  late final TextEditingController _primary;
  late final TextEditingController _inches;
  String? _error;
  @override
  void initState() {
    super.initState();
    final value = MeasurementUnits.metersToFeetAndInches(widget.meters);
    _primary = TextEditingController(
      text: widget.system == MeasurementSystem.metric
          ? widget.meters.toStringAsFixed(4)
          : '${value.feet}',
    );
    _inches = TextEditingController(text: value.inches.toStringAsFixed(4));
  }

  @override
  void dispose() {
    _primary.dispose();
    _inches.dispose();
    super.dispose();
  }

  double _number(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.')) ?? double.nan;
  void _save() {
    final primary = _number(_primary), inches = _number(_inches);
    final metric = widget.system == MeasurementSystem.metric;
    final meters = metric ? primary : (primary * 12 + inches) * 0.0254;
    if (!meters.isFinite ||
        meters < 0.05 ||
        primary < 0 ||
        (!metric && (inches < 0 || inches >= 12))) {
      setState(() => _error = AppLocalizations.of(context)!.planInvalidLength);
      return;
    }
    Navigator.pop(context, meters);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      scrollable: true,
      title: Text('${widget.roomName} · ${l.wall} ${widget.wallNumber}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.planLengthAnchor),
          TextField(
            key: const ValueKey('plan-wall-length'),
            controller: _primary,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText:
                  widget.system == MeasurementSystem.metric ? l.meters : l.feet,
              errorText: _error,
            ),
          ),
          if (widget.system == MeasurementSystem.imperial)
            TextField(
              controller: _inches,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(labelText: l.inches),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l.planPreview)),
      ],
    );
  }
}
