// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:app_futbol/main.dart';

void main() {
  test('parsea la respuesta real de ScoreBat', () {
    const payload =
        '{'
        '"response": ['
        '{'
        '"title": "Real Madrid - Barcelona", '
        '"competition": "ESPAÑA: LaLiga", '
        '"date": "2026-04-25T17:00:00+00:00", '
        '"thumbnail": "https://www.scorebat.com/og/m/og123.jpeg", '
        '"matchviewUrl": "https://www.scorebat.com/embed/matchview/123/", '
        '"homeTeam": {"name": "Real Madrid"}, '
        '"awayTeam": {"name": "Barcelona"}, '
        '"videos": ['
        '{'
        '"title": "Highlights", '
        '"embed": "<div><iframe src=\'https://www.scorebat.com/embed/v/abc123/?utm_source=api\'></iframe></div>"'
        '}'
        ']'
        '}'
        ']'
        '}';

    final decoded = jsonDecode(payload);
    final matches = ScoreBatRepository.parseApiResponse(decoded);

    expect(matches, isNotEmpty);
    expect(matches.first.homeTeam, 'Real Madrid');
    expect(matches.first.awayTeam, 'Barcelona');
    expect(
      matches.first.videos.first.embedUrl,
      'https://www.scorebat.com/embed/v/abc123/?utm_source=api',
    );
  });

  test('parsea embeds HTML codificados como los recibidos en la API', () {
    final matches = ScoreBatRepository.parseApiResponse({
      'response': [
        {
          'title': 'Angers - PSG',
          'homeTeam': {'name': 'Angers'},
          'awayTeam': {'name': 'PSG'},
          'videos': [
            {
              'title': 'Highlights',
              'embed': '&lt;div&gt;&lt;iframe src=\'https://www.scorebat.com/embed/v/69eede64541f0/?utm_source=api&amp;utm_medium=video&amp;utm_campaign=lgc\'&gt;&lt;/iframe&gt;&lt;/div&gt;',
            },
          ],
        },
      ],
    });

    expect(
      matches.single.videos.single.embedUrl,
      'https://www.scorebat.com/embed/v/69eede64541f0/?utm_source=api&utm_medium=video&utm_campaign=lgc',
    );
  });

  testWidgets('muestra la pantalla de fútbol', (WidgetTester tester) async {
    await tester.pumpWidget(const FootballApp());

    expect(find.text('Fútbol al día'), findsOneWidget);
    expect(find.text('Partidos'), findsOneWidget);
    expect(find.text('Videos'), findsOneWidget);
  });
}
