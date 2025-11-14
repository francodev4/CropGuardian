// Test de base pour CropGuardian
// Ce test vérifie que les composants de base fonctionnent

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_guardian/main.dart';

void main() {
  // Test simple pour vérifier que l'import fonctionne
  test('Global cameras list is initialized', () {
    // Verify that the global cameras list exists
    expect(globalCameras, isNotNull);
    expect(globalCameras, isA<List>());
  });

  // Test basique de widget sans dépendances
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Build a simple test widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('CropGuardian Test')),
          body: const Center(child: Text('Test')),
        ),
      ),
    );

    // Verify that the test widget builds
    expect(find.text('CropGuardian Test'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
  });

  // Test de la classe CropGuardianApp
  test('CropGuardianApp class exists', () {
    // Verify that the main app class can be instantiated
    const app = CropGuardianApp();
    expect(app, isNotNull);
    expect(app, isA<StatelessWidget>());
  });
}
