import 'package:flutter_test/flutter_test.dart';
import 'package:aula14_geolocalizacao_gps/main.dart';

void main() {
  testWidgets('App inicia corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());

    expect(find.text('Check-in & GPS'), findsOneWidget);
  });
}
