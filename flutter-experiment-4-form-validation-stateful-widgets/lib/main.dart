// =============================================================================
// EXPERIMENT 4 – FORM VALIDATION USING STATEFUL WIDGETS
// Application : Car Mileage Calculator
//
// Aim: Design and implement a Car Mileage Calculator using Flutter Forms,
// TextFormField, Input Widgets and Stateful Widgets. Validate user inputs and
// display the calculated mileage dynamically.
//
// Formula      : Mileage (km/l) = Distance Travelled (km) / Fuel Consumed (l)
// Efficiency   : mileage < 10        -> Poor Efficiency
//                10 <= mileage <= 15 -> Average Efficiency
//                mileage > 15        -> Excellent Efficiency
// =============================================================================

import 'package:flutter/material.dart';

// main() is the entry point of every Dart / Flutter program.
// runApp() inflates the given widget and attaches it to the screen.
void main() {
  runApp(const CarMileageApp());
}

// Theme colours (green and blue theme).
const Color kPrimaryBlue = Color(0xFF1565C0);
const Color kPrimaryGreen = Color(0xFF2E7D32);
const Color kLightBackground = Color(0xFFF1F8F6);

// -----------------------------------------------------------------------------
// MaterialApp – the root widget. It provides Material Design styling,
// theming, navigation and the title of the application.
// It is a StatelessWidget because the app-level configuration never changes.
// -----------------------------------------------------------------------------
class CarMileageApp extends StatelessWidget {
  const CarMileageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Mileage Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryBlue,
          primary: kPrimaryBlue,
          secondary: kPrimaryGreen,
        ),
        scaffoldBackgroundColor: kLightBackground,
      ),
      home: const MileageCalculatorPage(),
    );
  }
}

// -----------------------------------------------------------------------------
// StatefulWidget – a widget whose UI can change during the app's lifetime.
// A stateful widget is always written as TWO classes:
//   1. The widget class (this one) – an immutable blueprint.
//   2. The State class – holds the data (state) and builds the UI.
// createState() creates the associated State object.
// -----------------------------------------------------------------------------
class MileageCalculatorPage extends StatefulWidget {
  const MileageCalculatorPage({super.key});

  @override
  State<MileageCalculatorPage> createState() => _MileageCalculatorPageState();
}

// The State class. The leading underscore (_) makes it private to this file.
class _MileageCalculatorPageState extends State<MileageCalculatorPage> {
  // GlobalKey<FormState> – uniquely identifies the Form and gives access to
  // its FormState so we can call validate() and reset() on all fields at once.
  final _formKey = GlobalKey<FormState>();

  // TextEditingController – reads, sets and clears the text of a
  // TextFormField. One controller for each input field.
  final _distanceController = TextEditingController();
  final _fuelController = TextEditingController();

  // State variables – when these change inside setState(), the UI rebuilds.
  double? _mileage; // null means "no result yet" -> result card is hidden
  String _efficiency = '';
  double _distance = 0;
  double _fuel = 0;

  // dispose() releases the controllers' resources when the widget is removed.
  @override
  void dispose() {
    _distanceController.dispose();
    _fuelController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // VALIDATORS – a validator returns an error String to show below the field,
  // or null when the input is valid.
  // ---------------------------------------------------------------------------
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

  // Efficiency classification exactly as given in the reference PDF.
  String _classifyEfficiency(double mileage) {
    if (mileage < 10) {
      return 'Poor Efficiency';
    } else if (mileage <= 15) {
      return 'Average Efficiency';
    } else {
      return 'Excellent Efficiency';
    }
  }

  // Colour and icon used to highlight the efficiency classification.
  Color get _efficiencyColor {
    switch (_efficiency) {
      case 'Poor Efficiency':
        return const Color(0xFFC62828);
      case 'Average Efficiency':
        return const Color(0xFFEF6C00);
      default:
        return kPrimaryGreen;
    }
  }

  IconData get _efficiencyIcon {
    switch (_efficiency) {
      case 'Poor Efficiency':
        return Icons.trending_down;
      case 'Average Efficiency':
        return Icons.trending_flat;
      default:
        return Icons.trending_up;
    }
  }

  // ---------------------------------------------------------------------------
  // "Calculate Mileage" button handler.
  //   1. Validate the form.
  //   2. Calculate mileage = distance / fuel.
  //   3. Determine efficiency classification.
  //   4. Display the result using setState().
  // ---------------------------------------------------------------------------
  void _calculateMileage() {
    // Hide the keyboard.
    FocusScope.of(context).unfocus();

    // validate() runs every TextFormField validator; returns true if all pass.
    if (!_formKey.currentState!.validate()) {
      setState(() => _mileage = null); // hide any old result
      return;
    }

    final distance = double.parse(_distanceController.text.trim());
    final fuel = double.parse(_fuelController.text.trim());
    final mileage = distance / fuel;

    // setState() tells Flutter the state changed, so build() runs again and
    // the result card is shown with the new values.
    setState(() {
      _distance = distance;
      _fuel = fuel;
      _mileage = mileage;
      _efficiency = _classifyEfficiency(mileage);
    });
  }

  // "Clear" button handler – clears fields, validation messages and result.
  void _clearForm() {
    FocusScope.of(context).unfocus();
    _distanceController.clear();
    _fuelController.clear();
    _formKey.currentState!.reset(); // removes validation error messages
    setState(() {
      _mileage = null; // hides the result card
      _efficiency = '';
      _distance = 0;
      _fuel = 0;
    });
  }

  // Formats a number without unnecessary trailing zeros (300.0 -> 300).
  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  // ---------------------------------------------------------------------------
  // build() describes the UI. It is called again every time setState() runs.
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Scaffold – the basic Material page layout (AppBar + body).
    return Scaffold(
      // AppBar – the top bar showing the screen title.
      appBar: AppBar(
        title: const Text(
          'Car Mileage Calculator',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [kPrimaryBlue, kPrimaryGreen]),
          ),
        ),
      ),
      // SafeArea + SingleChildScrollView – makes the page scrollable so that
      // the keyboard or small screens never cause an overflow error.
      body: SafeArea(
        child: SingleChildScrollView(
          // Padding – adds empty space around its child.
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            // ConstrainedBox limits the width on tablets / desktops / browsers
            // so the form looks good on every screen size (responsive design).
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              // Column – arranges its children vertically.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  // The result card is shown only after a valid calculation.
                  if (_mileage != null) _buildResultCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Header with title and subtitle.
  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          '🚗 Car Mileage Calculator',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: kPrimaryBlue,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Calculate your vehicle's fuel efficiency.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  // Reusable InputDecoration – controls label, hint, icons, suffix and border.
  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required String suffix,
  }) {
    final radius = BorderRadius.circular(14);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: kPrimaryBlue),
      suffixText: suffix,
      filled: true,
      fillColor: const Color(0xFFF7FAFF),
      errorMaxLines: 2,
      border: OutlineInputBorder(borderRadius: radius),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Colors.blueGrey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: kPrimaryGreen, width: 2),
      ),
    );
  }

  // Card containing the Form with the two TextFormFields and two buttons.
  Widget _buildFormCard() {
    // Card – a Material panel with rounded corners and elevation (shadow).
    return Card(
      elevation: 6,
      shadowColor: kPrimaryBlue.withValues(alpha: 0.25),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        // Form – a container that groups TextFormFields so they can be
        // validated together using the GlobalKey<FormState>.
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TextFormField – a text input with built-in validation support.
              TextFormField(
                key: const Key('distanceField'),
                controller: _distanceController,
                // TextInputType – numeric keyboard that allows decimals.
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Distance Travelled',
                  hint: 'Enter distance in km',
                  icon: Icons.route,
                  suffix: 'km',
                ),
                validator: _validateDistance,
              ),
              const SizedBox(height: 18),
              TextFormField(
                key: const Key('fuelField'),
                controller: _fuelController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _calculateMileage(),
                decoration: _inputDecoration(
                  label: 'Fuel Consumed',
                  hint: 'Enter fuel consumed in litres',
                  icon: Icons.local_gas_station,
                  suffix: 'litres',
                ),
                validator: _validateFuel,
              ),
              const SizedBox(height: 24),
              // Row – arranges the two buttons horizontally.
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    // ElevatedButton – a raised Material button.
                    child: ElevatedButton.icon(
                      key: const Key('calculateButton'),
                      onPressed: _calculateMileage,
                      icon: const Icon(Icons.calculate),
                      label: const FittedBox(child: Text('Calculate Mileage')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      key: const Key('clearButton'),
                      onPressed: _clearForm,
                      icon: const Icon(Icons.refresh),
                      label: const FittedBox(child: Text('Clear')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Result card – shows mileage, unit, efficiency, distance and fuel.
  Widget _buildResultCard() {
    // Container – used here for the gradient background, rounded corners
    // and shadow of the result card.
    return Container(
      key: const Key('resultCard'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryBlue, kPrimaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryGreen.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'YOUR CAR MILEAGE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${_mileage!.toStringAsFixed(2)} km/l',
              key: const Key('mileageText'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_efficiencyIcon, color: _efficiencyColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _efficiency,
                    key: const Key('efficiencyText'),
                    style: TextStyle(
                      color: _efficiencyColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white38),
          const SizedBox(height: 12),
          _buildDetailRow(
              Icons.route, 'Distance', '${_formatNumber(_distance)} km'),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.local_gas_station, 'Fuel Used',
              '${_formatNumber(_fuel)} litres'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Text('$label:',
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
