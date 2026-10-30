// Widget tests for Experiment 4 – Car Mileage Calculator.
// Run with: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:car_mileage_calculator/main.dart';

Future<void> _enter(WidgetTester tester, String distance, String fuel) async {
  await tester.enterText(find.byKey(const Key('distanceField')), distance);
  await tester.enterText(find.byKey(const Key('fuelField')), fuel);
  await tester.tap(find.byKey(const Key('calculateButton')));
  await tester.pumpAndSettle();
}

Future<void> _expectResult(
    WidgetTester tester, String mileage, String efficiency) async {
  expect(find.byKey(const Key('resultCard')), findsOneWidget);
  expect(find.text(mileage), findsOneWidget);
  expect(find.text(efficiency), findsOneWidget);
}

void main() {
  testWidgets('Initial UI: header shown, result card hidden', (tester) async {
    await tester.pumpWidget(const CarMileageApp());
    expect(find.text('🚗 Car Mileage Calculator'), findsOneWidget);
    expect(find.text("Calculate your vehicle's fuel efficiency."),
        findsOneWidget);
    expect(find.byKey(const Key('resultCard')), findsNothing);
  });

  testWidgets('Test 1: Empty inputs show validation messages', (tester) async {
    await tester.pumpWidget(const CarMileageApp());
    await _enter(tester, '', '');
    expect(find.text('Please enter distance travelled.'), findsOneWidget);
    expect(find.text('Please enter fuel consumed.'), findsOneWidget);
    expect(find.byKey(const Key('resultCard')), findsNothing);
  });

  testWidgets('Test 2: Invalid text shows invalid number errors',
      (tester) async {
    await tester.pumpWidget(const CarMileageApp());
    await _enter(tester, 'abc', 'xyz');
    expect(find.text('Enter a valid number.'), findsNWidgets(2));
    expect(find.byKey(const Key('resultCard')), findsNothing);
  });

  testWidgets('Test 3: Zero / negative values', (tester) async {
    await tester.pumpWidget(const CarMileageApp());
    await _enter(tester, '0', '-5');
    expect(find.text('Distance must be greater than 0.'), findsOneWidget);
    expect(find.text('Fuel consumed must be greater than 0.'), findsOneWidget);
    await _enter(tester, '-10', '0');
    expect(find.text('Distance must be greater than 0.'), findsOneWidget);
    expect(find.text('Fuel consumed must be greater than 0.'), findsOneWidget);
    expect(find.byKey(const Key('resultCard')), findsNothing);
  });

  testWidgets('Test 4: 300 km / 20 l = 15.00 km/l Average', (tester) async {
    await tester.pumpWidget(const CarMileageApp());
    await _enter(tester, '300', '20');
    await _expectResult(tester, '15.00 km/l', 'Average Efficiency');
    expect(find.text('300 km'), findsOneWidget);
    expect(find.text('20 litres'), findsOneWidget);
  });

  testWidgets('Test 5: 125.5 km / 10 l = 12.55 km/l Average', (tester) async {
    await tester.pumpWidget(const CarMileageApp());
    await _enter(tester, '125.5', '10');
    await _expectResult(tester, '12.55 km/l', 'Average Efficiency');
  });

  testWidgets('Test 6: 180 km / 20 l = 9.00 km/l Poor', (tester) async {
    await tester.pumpWidget(const CarMileageApp());
    await _enter(tester, '180', '20');
    await _expectResult(tester, '9.00 km/l', 'Poor Efficiency');
  });

  testWidgets('Test 7: 400 km / 20 l = 20.00 km/l Excellent', (tester) async {
    await tester.pumpWidget(const CarMileageApp());
    await _enter(tester, '400', '20');
    await _expectResult(tester, '20.00 km/l', 'Excellent Efficiency');
  });

  testWidgets('Test 8: Clear resets fields, errors and result',
      (tester) async {
    await tester.pumpWidget(const CarMileageApp());
    await _enter(tester, '300', '20');
    expect(find.byKey(const Key('resultCard')), findsOneWidget);

    await tester.tap(find.byKey(const Key('clearButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('resultCard')), findsNothing);
    expect(find.text('300'), findsNothing);
    expect(find.text('20'), findsNothing);

    // Errors are also cleared.
    await _enter(tester, '', '');
    expect(find.text('Please enter distance travelled.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('clearButton')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter distance travelled.'), findsNothing);
    expect(find.text('Please enter fuel consumed.'), findsNothing);
  });

  testWidgets('No overflow on a small phone screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const CarMileageApp());
    await _enter(tester, '125.5', '10');
    expect(tester.takeException(), isNull);
  });
}
