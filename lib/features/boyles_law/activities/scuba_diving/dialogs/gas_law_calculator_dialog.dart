import 'package:flutter/material.dart';

/// Dialog for calculating gas laws (Boyle's, Charles', Combined)
class GasLawCalculatorDialog extends StatefulWidget {
  const GasLawCalculatorDialog({super.key});

  @override
  State<GasLawCalculatorDialog> createState() => _GasLawCalculatorDialogState();
}

class _GasLawCalculatorDialogState extends State<GasLawCalculatorDialog> {
  String _selectedLaw = 'Boyle\'s Law';
  final Map<String, TextEditingController> _controllers = {
    'P1': TextEditingController(),
    'V1': TextEditingController(),
    'T1': TextEditingController(),
    'P2': TextEditingController(),
    'V2': TextEditingController(),
    'T2': TextEditingController(),
  };
  String _result = '';

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    try {
      if (_selectedLaw == 'Boyle\'s Law') {
        // P1 * V1 = P2 * V2
        final p1 = double.tryParse(_controllers['P1']!.text);
        final v1 = double.tryParse(_controllers['V1']!.text);
        final p2 = double.tryParse(_controllers['P2']!.text);
        final v2 = double.tryParse(_controllers['V2']!.text);

        if (p1 != null && v1 != null && p2 != null && v2 == null) {
          final result = (p1 * v1) / p2;
          setState(() => _result = 'V2 = ${result.toStringAsFixed(2)} L');
        } else if (p1 != null && v1 != null && p2 == null && v2 != null) {
          final result = (p1 * v1) / v2;
          setState(() => _result = 'P2 = ${result.toStringAsFixed(2)} atm');
        } else if (p1 != null && v1 == null && p2 != null && v2 != null) {
          final result = (p2 * v2) / p1;
          setState(() => _result = 'V1 = ${result.toStringAsFixed(2)} L');
        } else if (p1 == null && v1 != null && p2 != null && v2 != null) {
          final result = (p2 * v2) / v1;
          setState(() => _result = 'P1 = ${result.toStringAsFixed(2)} atm');
        } else {
          setState(() => _result = 'Please leave one value empty to calculate');
        }
      } else if (_selectedLaw == 'Charles\' Law') {
        // V1 / T1 = V2 / T2
        final v1 = double.tryParse(_controllers['V1']!.text);
        final t1 = double.tryParse(_controllers['T1']!.text);
        final v2 = double.tryParse(_controllers['V2']!.text);
        final t2 = double.tryParse(_controllers['T2']!.text);

        if (v1 != null && t1 != null && v2 != null && t2 == null) {
          final result = (v2 * t1) / v1;
          setState(() => _result = 'T2 = ${result.toStringAsFixed(2)} K');
        } else if (v1 != null && t1 != null && v2 == null && t2 != null) {
          final result = (v1 * t2) / t1;
          setState(() => _result = 'V2 = ${result.toStringAsFixed(2)} L');
        } else {
          setState(() => _result = 'Please leave one value empty to calculate');
        }
      } else if (_selectedLaw == 'Combined Gas Law') {
        // P1 * V1 / T1 = P2 * V2 / T2
        final p1 = double.tryParse(_controllers['P1']!.text);
        final v1 = double.tryParse(_controllers['V1']!.text);
        final t1 = double.tryParse(_controllers['T1']!.text);
        final p2 = double.tryParse(_controllers['P2']!.text);
        final v2 = double.tryParse(_controllers['V2']!.text);
        final t2 = double.tryParse(_controllers['T2']!.text);

        int emptyCount = 0;
        String? emptyVar;
        if (p1 == null) { emptyCount++; emptyVar = 'P1'; }
        if (v1 == null) { emptyCount++; emptyVar = 'V1'; }
        if (t1 == null) { emptyCount++; emptyVar = 'T1'; }
        if (p2 == null) { emptyCount++; emptyVar = 'P2'; }
        if (v2 == null) { emptyCount++; emptyVar = 'V2'; }
        if (t2 == null) { emptyCount++; emptyVar = 'T2'; }

        if (emptyCount == 1 && emptyVar != null) {
          final p1Val = p1 ?? 0;
          final v1Val = v1 ?? 0;
          final t1Val = t1 ?? 0;
          final p2Val = p2 ?? 0;
          final v2Val = v2 ?? 0;
          final t2Val = t2 ?? 0;

          double result = 0;
          if (emptyVar == 'P1') {
            result = (p2Val * v2Val * t1Val) / (v1Val * t2Val);
            setState(() => _result = 'P1 = ${result.toStringAsFixed(2)} atm');
          } else if (emptyVar == 'V1') {
            result = (p2Val * v2Val * t1Val) / (p1Val * t2Val);
            setState(() => _result = 'V1 = ${result.toStringAsFixed(2)} L');
          } else if (emptyVar == 'T1') {
            result = (p1Val * v1Val * t2Val) / (p2Val * v2Val);
            setState(() => _result = 'T1 = ${result.toStringAsFixed(2)} K');
          } else if (emptyVar == 'P2') {
            result = (p1Val * v1Val * t2Val) / (v2Val * t1Val);
            setState(() => _result = 'P2 = ${result.toStringAsFixed(2)} atm');
          } else if (emptyVar == 'V2') {
            result = (p1Val * v1Val * t2Val) / (p2Val * t1Val);
            setState(() => _result = 'V2 = ${result.toStringAsFixed(2)} L');
          } else if (emptyVar == 'T2') {
            result = (p2Val * v2Val * t1Val) / (p1Val * v1Val);
            setState(() => _result = 'T2 = ${result.toStringAsFixed(2)} K');
          }
        } else {
          setState(() => _result = 'Please leave exactly one value empty to calculate');
        }
      }
    } catch (e) {
      setState(() => _result = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gas Law Calculator',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedLaw,
                decoration: const InputDecoration(
                  labelText: 'Select Law',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Boyle\'s Law', child: Text('Boyle\'s Law')),
                  DropdownMenuItem(value: 'Charles\' Law', child: Text('Charles\' Law')),
                  DropdownMenuItem(value: 'Combined Gas Law', child: Text('Combined Gas Law')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLaw = value!;
                    _result = '';
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_selectedLaw == 'Boyle\'s Law')
                Column(
                  children: [
                    TextField(
                      controller: _controllers['P1'],
                      decoration: const InputDecoration(
                        labelText: 'P1 (atm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers['V1'],
                      decoration: const InputDecoration(
                        labelText: 'V1 (L)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers['P2'],
                      decoration: const InputDecoration(
                        labelText: 'P2 (atm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers['V2'],
                      decoration: const InputDecoration(
                        labelText: 'V2 (L) - Leave empty to calculate',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    const Text('Formula: P1 × V1 = P2 × V2'),
                  ],
                )
              else if (_selectedLaw == 'Charles\' Law')
                Column(
                  children: [
                    TextField(
                      controller: _controllers['V1'],
                      decoration: const InputDecoration(
                        labelText: 'V1 (L)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers['T1'],
                      decoration: const InputDecoration(
                        labelText: 'T1 (K)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers['V2'],
                      decoration: const InputDecoration(
                        labelText: 'V2 (L) - Leave empty to calculate',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers['T2'],
                      decoration: const InputDecoration(
                        labelText: 'T2 (K) - Leave empty to calculate',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    const Text('Formula: V1 / T1 = V2 / T2'),
                  ],
                )
              else
                Column(
                  children: [
                    TextField(
                      controller: _controllers['P1'],
                      decoration: const InputDecoration(
                        labelText: 'P1 (atm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers['V1'],
                      decoration: const InputDecoration(
                        labelText: 'V1 (L)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers['T1'],
                      decoration: const InputDecoration(
                        labelText: 'T1 (K)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers['P2'],
                      decoration: const InputDecoration(
                        labelText: 'P2 (atm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers['V2'],
                      decoration: const InputDecoration(
                        labelText: 'V2 (L)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controllers['T2'],
                      decoration: const InputDecoration(
                        labelText: 'T2 (K) - Leave one empty to calculate',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    const Text('Formula: P1 × V1 / T1 = P2 × V2 / T2'),
                  ],
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculate'),
              ),
              if (_result.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

