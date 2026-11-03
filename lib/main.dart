// ============================================================
// Experiment 4: Form Validation using Stateful Widgets
// App : Car Mileage Calculator ("Fuel Gauge" edition)
//
// Mileage (km/l) = Distance (km) / Fuel (litres)
//   below 10    -> Poor Efficiency
//   10 to 15    -> Average Efficiency
//   above 15    -> Excellent Efficiency
//
// Concepts: StatefulWidget, setState, Form, GlobalKey<FormState>,
// TextFormField, TextEditingController, validators, InputDecoration,
// TextInputType, Card/Container/Row/Column, SingleChildScrollView.
// ============================================================

import 'package:flutter/material.dart';

void main() {
  runApp(const CarMileageApp());
}

// -------------------------------------------------------
// Palette – graphite garage with orange and lime accents
// -------------------------------------------------------
const Color kGraphite = Color(0xFF0F1115);
const Color kPanel = Color(0xFF1A1D24);
const Color kOrange = Color(0xFFFF6B35);
const Color kLime = Color(0xFFB8F34A);
const Color kAmber = Color(0xFFFFC145);
const Color kRed = Color(0xFFFF4D6D);
const Color kSoft = Color(0xFF9AA3B2);

class CarMileageApp extends StatelessWidget {
  const CarMileageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Mileage Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kGraphite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kOrange,
          brightness: Brightness.dark,
        ),
      ),
      home: const MileageCalculatorPage(),
    );
  }
}

// -------------------------------------------------------
// StatefulWidget: the page owns the form and the result
// -------------------------------------------------------
class MileageCalculatorPage extends StatefulWidget {
  const MileageCalculatorPage({super.key});

  @override
  State<MileageCalculatorPage> createState() => _MileageCalculatorPageState();
}

class _MileageCalculatorPageState extends State<MileageCalculatorPage> {
  // Identifies the Form so validate()/reset() reach every field
  final _formKey = GlobalKey<FormState>();

  // One controller per input
  final _distanceController = TextEditingController();
  final _fuelController = TextEditingController();

  // State: null mileage means "no result yet", so the result card is hidden
  double? _mileage;
  String _efficiency = '';
  double _distance = 0;
  double _fuel = 0;

  @override
  void dispose() {
    _distanceController.dispose();
    _fuelController.dispose();
    super.dispose();
  }

  // ---------------- Validators ----------------
  // Return an error message, or null when the value is valid.
  String? _validateDistance(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter distance travelled.';
    }
    final distance = double.tryParse(value.trim());
    if (distance == null || !distance.isFinite) {
      return 'Enter a valid number.';
    }
    if (distance <= 0) {
      return 'Distance must be greater than 0.';
    }
    return null;
  }

  String? _validateFuel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter fuel consumed.';
    }
    final fuel = double.tryParse(value.trim());
    if (fuel == null || !fuel.isFinite) {
      return 'Enter a valid number.';
    }
    if (fuel <= 0) {
      return 'Fuel consumed must be greater than 0.';
    }
    return null;
  }

  String _classify(double mileage) {
    if (mileage < 10) return 'Poor Efficiency';
    if (mileage <= 15) return 'Average Efficiency';
    return 'Excellent Efficiency';
  }

  Color get _tone {
    switch (_efficiency) {
      case 'Poor Efficiency':
        return kRed;
      case 'Average Efficiency':
        return kAmber;
      default:
        return kLime;
    }
  }

  IconData get _toneIcon {
    switch (_efficiency) {
      case 'Poor Efficiency':
        return Icons.trending_down;
      case 'Average Efficiency':
        return Icons.trending_flat;
      default:
        return Icons.trending_up;
    }
  }

  // ---------------- Actions ----------------
  void _calculate() {
    FocusScope.of(context).unfocus();

    // Runs every validator; false means at least one field is invalid
    if (!_formKey.currentState!.validate()) {
      setState(() => _mileage = null);
      return;
    }

    final distance = double.parse(_distanceController.text.trim());
    final fuel = double.parse(_fuelController.text.trim());
    final mileage = distance / fuel;

    // setState rebuilds the page and reveals the result card
    setState(() {
      _distance = distance;
      _fuel = fuel;
      _mileage = mileage;
      _efficiency = _classify(mileage);
    });
  }

  void _clear() {
    FocusScope.of(context).unfocus();
    _distanceController.clear();
    _fuelController.clear();
    _formKey.currentState!.reset(); // removes the error messages
    setState(() {
      _mileage = null;
      _efficiency = '';
      _distance = 0;
      _fuel = 0;
    });
  }

  // 300.0 -> "300", 125.5 -> "125.5"
  String _fmt(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kGraphite,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'FUEL GAUGE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 16,
            color: kOrange,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  _formCard(),
                  const SizedBox(height: 20),
                  if (_mileage != null) _resultCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      children: [
        Text(
          '🚗 Car Mileage Calculator',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Calculate your vehicle's fuel efficiency.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: kSoft),
        ),
      ],
    );
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
    required String unit,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: kOrange),
      suffixText: unit,
      suffixStyle: const TextStyle(color: kLime, fontWeight: FontWeight.w700),
      filled: true,
      fillColor: kGraphite,
      border: border(const Color(0xFF2C313B)),
      enabledBorder: border(const Color(0xFF2C313B)),
      focusedBorder: border(kOrange, 1.8),
      errorBorder: border(kRed),
      focusedErrorBorder: border(kRed, 1.8),
      errorStyle: const TextStyle(color: kRed),
    );
  }

  Widget _formCard() {
    return Card(
      color: kPanel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFF262B35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Trip details',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('distanceField'),
                controller: _distanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: _validateDistance,
                decoration: _decoration(
                  label: 'Distance Travelled',
                  hint: 'e.g. 300',
                  icon: Icons.route,
                  unit: 'km',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('fuelField'),
                controller: _fuelController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                validator: _validateFuel,
                onFieldSubmitted: (_) => _calculate(),
                decoration: _decoration(
                  label: 'Fuel Consumed',
                  hint: 'e.g. 20',
                  icon: Icons.local_gas_station,
                  unit: 'litres',
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    key: const Key('calculateButton'),
                    onPressed: _calculate,
                    style: FilledButton.styleFrom(
                      backgroundColor: kOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.speed),
                    label: const Text('Calculate Mileage'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    key: const Key('clearButton'),
                    onPressed: _clear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kSoft,
                      side: const BorderSide(color: Color(0xFF3A404C)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultCard() {
    final mileage = _mileage!;
    return Container(
      key: const Key('resultCard'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _tone.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _tone.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'YOUR MILEAGE',
            style: TextStyle(
                color: kSoft,
                fontSize: 12,
                letterSpacing: 3,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              '${mileage.toStringAsFixed(2)} km/l',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: _tone,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _gauge(mileage),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _tone.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_toneIcon, size: 18, color: _tone),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _efficiency,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: _tone, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFF2C313B)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _detail(
                    Icons.route, 'Distance', '${_fmt(_distance)} km'),
              ),
              Expanded(
                child: _detail(Icons.local_gas_station, 'Fuel',
                    '${_fmt(_fuel)} litres'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Three-band gauge (red / amber / lime) with a marker at the mileage.
  // Scale runs from 0 to 25 km/l; larger values pin to the right edge.
  Widget _gauge(double mileage) {
    final fraction = (mileage / 25).clamp(0.0, 1.0);
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, c) {
            const markerSize = 14.0;
            final left = fraction * (c.maxWidth - markerSize);
            return SizedBox(
              height: 22,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      children: const [
                        Expanded(flex: 10, child: SizedBox(height: 8, child: ColoredBox(color: kRed))),
                        Expanded(flex: 5, child: SizedBox(height: 8, child: ColoredBox(color: kAmber))),
                        Expanded(flex: 10, child: SizedBox(height: 8, child: ColoredBox(color: kLime))),
                      ],
                    ),
                  ),
                  Positioned(
                    left: left,
                    child: Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: kGraphite, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        const Row(
          children: [
            Expanded(child: _LegendLabel('Poor <10', Alignment.centerLeft)),
            Expanded(child: _LegendLabel('Average 10-15', Alignment.center)),
            Expanded(child: _LegendLabel('Excellent >15', Alignment.centerRight)),
          ],
        ),
      ],
    );
  }

  Widget _detail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: kOrange, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: kSoft, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// Small gauge legend label that shrinks instead of overflowing on narrow screens
class _LegendLabel extends StatelessWidget {
  const _LegendLabel(this.text, this.alignment);

  final String text;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: const TextStyle(color: kSoft, fontSize: 10)),
      ),
    );
  }
}
