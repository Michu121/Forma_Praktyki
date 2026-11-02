import 'package:flutter/material.dart';

import 'app_colors.dart';

class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({super.key});

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double? _bmi;
  String? _error;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculate() {
    final height = double.tryParse(_heightController.text.replaceAll(',', '.'));
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    if (height == null ||
        weight == null ||
        !height.isFinite ||
        !weight.isFinite ||
        height <= 0 ||
        weight <= 0 ||
        height > 300 ||
        weight > 500) {
      setState(() {
        _bmi = null;
        _error = 'Podaj poprawny wzrost (cm) i masę ciała (kg).';
      });
      return;
    }

    final heightInMeters = height / 100;
    setState(() {
      _bmi = weight / (heightInMeters * heightInMeters);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    final bmi = _bmi;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator BMI'),
        backgroundColor: colors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Sprawdź swój wskaźnik BMI',
            style: TextStyle(
              color: colors.foreground,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wprowadź aktualny wzrost i masę ciała.',
            style: TextStyle(color: colors.muted),
          ),
          const SizedBox(height: 24),
          _numberField(
            controller: _heightController,
            label: 'Wzrost',
            suffix: 'cm',
          ),
          const SizedBox(height: 14),
          _numberField(
            controller: _weightController,
            label: 'Masa ciała',
            suffix: 'kg',
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Color(0xFFCF4F4F))),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Oblicz BMI'),
          ),
          if (bmi != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    bmi.toStringAsFixed(1),
                    key: const Key('bmi-result'),
                    style: TextStyle(
                      color: colors.accent,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _category(bmi),
                    style: TextStyle(
                      color: colors.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'BMI jest orientacyjnym wskaźnikiem dla dorosłych i nie zastępuje '
            'konsultacji medycznej. Nie uwzględnia m.in. składu ciała.',
            style: TextStyle(color: colors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      border: const OutlineInputBorder(),
    ),
  );

  String _category(double bmi) {
    if (bmi < 18.5) return 'Poniżej zakresu referencyjnego';
    if (bmi < 25) return 'Zakres referencyjny';
    if (bmi < 30) return 'Powyżej zakresu referencyjnego';
    return 'Otyłość według klasyfikacji BMI';
  }
}
