import 'package:flutter/material.dart';
import '../../../utils/unit_converter.dart';

/// Dialog for converting units (Volume, Pressure, Temperature)
class UnitConversionDialog extends StatefulWidget {
  final String title;
  final double currentValue;
  final dynamic currentUnit;
  final List<dynamic> units;
  final Function(double, dynamic) onValueChanged;
  final String Function(double, dynamic) formatValue;

  const UnitConversionDialog({
    super.key,
    required this.title,
    required this.currentValue,
    required this.currentUnit,
    required this.units,
    required this.onValueChanged,
    required this.formatValue,
  });

  @override
  State<UnitConversionDialog> createState() => _UnitConversionDialogState();
}

class _UnitConversionDialogState extends State<UnitConversionDialog> {
  late double _value;
  late dynamic _selectedUnit;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
    _selectedUnit = widget.currentUnit;
    _controller.text = _value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue() {
    final newValue = double.tryParse(_controller.text) ?? _value;
    setState(() {
      _value = newValue;
    });
    widget.onValueChanged(_value, _selectedUnit);
  }

  void _onUnitChanged(dynamic unit) {
    if (unit != null) {
      setState(() {
        _selectedUnit = unit;
      });
      widget.onValueChanged(_value, _selectedUnit);
    }
  }

  String _getUnitName(dynamic unit) {
    if (unit is VolumeUnit) {
      return unit.symbol;
    } else if (unit is PressureUnit) {
      return unit.symbol;
    } else if (unit is TemperatureUnit) {
      return unit.symbol;
    }
    return unit.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateValue(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<dynamic>(
            value: _selectedUnit,
            decoration: const InputDecoration(
              labelText: 'Unit',
              border: OutlineInputBorder(),
            ),
            items: widget.units.map((unit) {
              return DropdownMenuItem<dynamic>(
                value: unit,
                child: Text(_getUnitName(unit)),
              );
            }).toList(),
            onChanged: _onUnitChanged,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Current: ${widget.formatValue(_value, _selectedUnit)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

