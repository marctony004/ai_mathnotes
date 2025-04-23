import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';



import 'package:ai_mathnotes/math_notes_app.dart'; // ✅ Required to find MathNotesApp


void main() {
  testWidgets('MathNotesApp builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MathNotesApp());

    // Confirm the MaterialApp loads
    expect(find.byType(MaterialApp), findsOneWidget);

    // Optional: confirm folder home screen appears
    expect(find.text('📁 Your Math Folders'), findsOneWidget);
  });
}
