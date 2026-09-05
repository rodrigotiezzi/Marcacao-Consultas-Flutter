import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:marcacao_consultas_flutter/main.dart';

void main() {
  testWidgets('Login com paciente de teste abre a Home filtrada', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MarcacaoConsultasApp());
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo!'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '131.105.218-35');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Maria Silva!'), findsOneWidget);
    expect(find.text('+ Agendar Nova Consulta'), findsOneWidget);
    expect(find.text('Você ainda não tem consultas agendadas'), findsOneWidget);
  });
}


