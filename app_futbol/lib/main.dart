import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

const _legacyFeedAsset = 'assets/data/scorebat_legacy_feed.json';

void main() => runApp(const FootballApp());

class FootballApp extends StatelessWidget {
  const FootballApp({super.key, this.repository});

  final ScoreBatRepository? repository;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF07151F);
    const surface = Color(0xFF102632);
    const green = Color(0xFF7DF1B7);
    return MaterialApp(
      title: 'Fútbol al día',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: green,
          secondary: Color(0xFF69C6FF),
          surface: surface,
          error: Color(0xFFFF8A8A),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: FootballHomePage(
        repository: repository ?? const ScoreBatRepository(),
      ),
    );
  }
}

enum FeedType { featured, live }

enum AppSection { matches, videos, history }

class FootballHomePage extends StatefulWidget {
  const FootballHomePage({super.key, required this.repository});

  final ScoreBatRepository repository;

  @override
  State<FootballHomePage> createState() => _FootballHomePageState();
}

class _FootballHomePageState extends State<FootballHomePage> {
  FeedType _feedType = FeedType.featured;
  AppSection _section = AppSection.matches;
  List<FootballMatch> _matches = const [];
  bool _loading = true;
  bool _isArchive = false;
  String? _error;
  String? _notice;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final feed = await widget.repository.loadFeed(_feedType);
      if (!mounted) return;
      setState(() {
        _matches = feed.matches;
        _isArchive = feed.isArchive;
        _notice = feed.notice;
        _loading = false;
      });
    } on ScoreBatException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No fue posible cargar los partidos. Revisa tu conexión.';
        _loading = false;
      });
    }
  }

  void _setFeed(FeedType value) {
    if (_feedType == value) return;
    setState(() => _feedType = value);
    _load();
  }

  void _setSection(int index) {
    final value = AppSection.values[index];
    if (_section == value) return;
    setState(() => _section = value);
    if (value == AppSection.history && _feedType != FeedType.featured) {
      setState(() => _feedType = FeedType.featured);
      _load();
    }
  }

  List<FootballMatch> get _filtered {
    final query = _query.trim().toLowerCase();
    return _matches.where((match) {
      final sectionMatch = switch (_section) {
        AppSection.matches => true,
        AppSection.videos => match.videos.isNotEmpty,
        AppSection.history =>
          match.date != null &&
              match.date!.isBefore(
                DateTime.now().subtract(const Duration(days: 1)),
              ),
      };
      final textMatch =
          query.isEmpty ||
          '${match.title} ${match.competition}'.toLowerCase().contains(query);
      return sectionMatch && textMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _filtered;
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _section.index,
        onDestinationSelected: _setSection,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer),
            label: 'Partidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle_fill),
            label: 'Videos',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: _Header(
                    section: _section,
                    isArchive: _isArchive,
                    feedType: _feedType,
                    onFeedChanged: _setFeed,
                    onSearchChanged: (value) => setState(() => _query = value),
                  ),
                ),
              ),
              if (_isArchive)
                SliverToBoxAdapter(
                  child: _DemoBanner(onTap: _showArchiveInfo, message: _notice),
                ),
              if (_loading)
                const SliverFillRemaining(child: _LoadingView())
              else if (_error != null)
                SliverFillRemaining(
                  child: _ErrorView(message: _error!, onRetry: _load),
                )
              else if (matches.isEmpty)
                SliverFillRemaining(
                  child: _EmptyView(section: _section, onRefresh: _load),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  sliver: SliverList.separated(
                    itemCount: matches.length,
                    itemBuilder: (context, index) => MatchCard(
                      match: matches[index],
                      showsStream: _feedType == FeedType.live,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              MatchDetailPage(match: matches[index]),
                        ),
                      ),
                    ),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showArchiveInfo() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catálogo incluido',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Los 50 partidos y 74 videos que compartiste se incluyeron dentro de la aplicación.',
            ),
            SizedBox(height: 12),
            Text(
              'Es un archivo histórico: ScoreBat dejó de actualizar este endpoint el 27 de abril de 2026.',
            ),
            SizedBox(height: 12),
            Text(
              'La aplicación funciona sin token y sin consultar la API. Para datos nuevos se deberá migrar a la API actual de ScoreBat.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.section,
    required this.isArchive,
    required this.feedType,
    required this.onFeedChanged,
    required this.onSearchChanged,
  });

  final AppSection section;
  final bool isArchive;
  final FeedType feedType;
  final ValueChanged<FeedType> onFeedChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final title = switch (section) {
      AppSection.matches => 'Fútbol al día',
      AppSection.videos => 'Videos oficiales',
      AppSection.history => 'Partidos anteriores',
    };
    final subtitle = switch (section) {
      AppSection.matches => 'Archivo de resultados y videos de ScoreBat.',
      AppSection.videos => 'Resúmenes incluidos en el catálogo.',
      AppSection.history => 'Encuentros históricos del archivo local.',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .65),
                    ),
                  ),
                ],
              ),
            ),
            _SourceBadge(isArchive: isArchive),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Buscar equipo o competición',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        if (section != AppSection.history) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Catálogo'),
                selected: feedType == FeedType.featured,
                onSelected: (_) => onFeedChanged(FeedType.featured),
              ),
              ChoiceChip(
                avatar: const Icon(Icons.podcasts, size: 18),
                label: const Text('Con transmisión'),
                selected: feedType == FeedType.live,
                onSelected: (_) => onFeedChanged(FeedType.live),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.isArchive});

  final bool isArchive;

  @override
  Widget build(BuildContext context) {
    final color = isArchive
        ? Colors.orangeAccent
        : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: .4)),
      ),
      child: Text(
        isArchive ? 'ARCHIVO' : 'SCOREBAT',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.onTap, this.message});

  final VoidCallback onTap;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
      child: Material(
        color: const Color(0xFF193645),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF7DF1B7)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message ?? 'Partidos de demostración. Toca para conectar ScoreBat.',
                  ),
                ),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    required this.showsStream,
    required this.onTap,
  });

  final FootballMatch match;
  final bool showsStream;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasVideos = match.videos.isNotEmpty;
    return Material(
      color: const Color(0xFF102632),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            if (match.thumbnailUrl.isNotEmpty)
              Positioned.fill(
                child: Opacity(
                  opacity: .14,
                  child: Image.network(match.thumbnailUrl, fit: BoxFit.cover),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          match.competition,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .64),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      _StatusPill(
                        showsStream: showsStream,
                        label: formatMatchDate(match.date),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    match.homeTeam,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      'vs',
                      style: TextStyle(
                        color: Color(0xFF7DF1B7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    match.awayTeam,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Icon(
                        hasVideos
                            ? Icons.play_circle_fill
                            : Icons.bar_chart_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          hasVideos
                              ? '${match.videos.length} ${match.videos.length == 1 ? 'video disponible' : 'videos disponibles'}'
                              : 'Ver ficha y estadísticas',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .78),
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.showsStream, required this.label});

  final bool showsStream;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = showsStream ? const Color(0xFF69C6FF) : Colors.white70;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        showsStream ? 'CON STREAM' : label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class MatchDetailPage extends StatelessWidget {
  const MatchDetailPage({super.key, required this.match});

  final FootballMatch match;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del partido')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF163D4A), Color(0xFF102632)],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                Text(
                  match.competition,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF7DF1B7)),
                ),
                const SizedBox(height: 20),
                Text(
                  match.homeTeam,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  match.awayTeam,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  formatMatchDate(match.date),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (match.matchViewUrl.isNotEmpty) ...[
            const Text(
              'Marcador y estadísticas',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Consulta los eventos, alineaciones y datos disponibles de este encuentro.',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  _openWeb(context, 'Estadísticas', match.matchViewUrl),
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text('Abrir ficha de ScoreBat'),
            ),
            const SizedBox(height: 28),
          ],
          Text(
            'Videos',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (match.videos.isEmpty)
            const _NoVideosCard()
          else
            ...match.videos.map(
              (video) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _VideoTile(
                  video: video,
                  onTap: () => _openWeb(context, video.title, video.embedUrl),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openWeb(BuildContext context, String title, String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScoreBatWebPage(title: title, url: url),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video, required this.onTap});

  final MatchVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF102632),
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF234956),
          child: Icon(Icons.play_arrow_rounded, color: Color(0xFF7DF1B7)),
        ),
        title: Text(
          video.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: const Text('Fuente oficial vía ScoreBat'),
        trailing: const Icon(Icons.open_in_new),
      ),
    );
  }
}

class _NoVideosCard extends StatelessWidget {
  const _NoVideosCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF102632),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.videocam_off_outlined),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aún no hay videos oficiales disponibles para este partido.',
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreBatWebPage extends StatefulWidget {
  const ScoreBatWebPage({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<ScoreBatWebPage> createState() => _ScoreBatWebPageState();
}

class _ScoreBatWebPageState extends State<ScoreBatWebPage> {
  late final WebViewController _controller;
  final int _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: _controller.reload,
          ),
        ],
      ),

      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_progress < 100 && _error == null)
            LinearProgressIndicator(value: _progress / 100),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 42),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _error = null);
                        _controller.reload();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 14),
        Text('Actualizando partidos...'),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.section, required this.onRefresh});

  final AppSection section;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final text = switch (section) {
      AppSection.matches => 'No hay partidos disponibles en este momento.',
      AppSection.videos => 'No encontramos videos para este filtro.',
      AppSection.history => 'No hay partidos anteriores en el feed actual.',
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_soccer_outlined, size: 48),
          const SizedBox(height: 14),
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onRefresh, child: const Text('Actualizar')),
        ],
      ),
    );
  }
}

class ScoreBatRepository {
  const ScoreBatRepository();

  static const _apiUrl = 'https://www.scorebat.com/video-api/v1/';

  static List<FootballMatch> parseApiResponse(Object? decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw const ScoreBatException(
        'La respuesta de ScoreBat no tiene el formato esperado.',
      );
    }

    final response = decoded['response'];
    if (response is! List) {
      throw const ScoreBatException(
        'La API de ScoreBat no devolvió una lista de partidos.',
      );
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(FootballMatch.fromJson)
        .where((match) => match.title.isNotEmpty)
        .toList();
  }

  Future<FeedResponse> loadFeed(FeedType type) async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode != 200) {
        throw const ScoreBatException(
          'ScoreBat respondió con un error de servidor.',
        );
      }

      final matches = parseApiResponse(jsonDecode(response.body));
      final filtered = _filterMatches(matches, type);

      return FeedResponse(
        matches: filtered,
        isArchive: false,
        notice: 'Datos en vivo desde la API actual de ScoreBat.',
      );
    } on ScoreBatException {
      return _loadLegacyFallback(type);
    } on FormatException {
      return _loadLegacyFallback(
        type,
        errorMessage: 'El JSON recibido de ScoreBat no es válido.',
      );
    } on http.ClientException {
      return _loadLegacyFallback(
        type,
        errorMessage: 'No se pudo conectar con la API en este momento.',
      );
    } catch (_) {
      return _loadLegacyFallback(
        type,
        errorMessage: 'No se pudo cargar la información de ScoreBat.',
      );
    }
  }

  Future<FeedResponse> _loadLegacyFallback(
    FeedType type, {
    String? errorMessage,
  }) async {
    try {
      final content = await rootBundle.loadString(_legacyFeedAsset);
      final decoded = jsonDecode(content);
      var matches = parseApiResponse(decoded);
      matches = _filterMatches(matches, type);
      return FeedResponse(
        matches: matches,
        isArchive: true,
        notice: errorMessage ?? 'Archivo local de ScoreBat: sin actualizaciones desde el 27 de abril de 2026.',
      );
    } on ScoreBatException {
      rethrow;
    } on FormatException {
      throw const ScoreBatException(
        'El archivo de ScoreBat no contiene JSON válido.',
      );
    } catch (_) {
      throw const ScoreBatException('No se pudo leer el catálogo incluido.');
    }
  }

  List<FootballMatch> _filterMatches(
    List<FootballMatch> matches,
    FeedType type,
  ) {
    if (type != FeedType.live) return matches;
    return matches
        .where(
          (match) => match.videos.any(
            (video) =>
                video.title.toLowerCase().contains('live stream') ||
                video.title.toLowerCase().contains('stream'),
          ),
        )
        .toList();
  }
}

class FeedResponse {
  const FeedResponse({
    required this.matches,
    required this.isArchive,
    this.notice,
  });

  final List<FootballMatch> matches;
  final bool isArchive;
  final String? notice;
}

class ScoreBatException implements Exception {
  const ScoreBatException(this.message);

  final String message;
}

class FootballMatch {
  const FootballMatch({
    required this.title,
    required this.competition,
    required this.date,
    required this.thumbnailUrl,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchViewUrl,
    required this.videos,
  });

  final String title;
  final String competition;
  final DateTime? date;
  final String thumbnailUrl;
  final String homeTeam;
  final String awayTeam;
  final String matchViewUrl;
  final List<MatchVideo> videos;

  factory FootballMatch.fromJson(Map<String, dynamic> json) {
    final title = json['title']?.toString() ?? 'Partido sin nombre';
    final teams = title.split(' - ');
    final home = json['homeTeam'];
    final away = json['awayTeam'];
    final rawVideos = json['videos'];
    return FootballMatch(
      title: title,
      competition:
          json['competition']?.toString() ?? 'Competición no disponible',
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      thumbnailUrl: json['thumbnail']?.toString() ?? '',
      homeTeam: home is Map
          ? home['name']?.toString() ?? teams.first
          : teams.first,
      awayTeam: away is Map
          ? away['name']?.toString() ??
                (teams.length > 1 ? teams.last : 'Rival por confirmar')
          : (teams.length > 1 ? teams.last : 'Rival por confirmar'),
      matchViewUrl: json['matchviewUrl']?.toString() ?? '',
      videos: rawVideos is List
          ? rawVideos
                .whereType<Map<String, dynamic>>()
                .map(MatchVideo.fromJson)
                .where((video) => video.embedUrl.isNotEmpty)
                .toList()
          : const [],
    );
  }
}

class MatchVideo {
  const MatchVideo({required this.title, required this.embedUrl});

  final String title;
  final String embedUrl;

  factory MatchVideo.fromJson(Map<String, dynamic> json) {
    final embed = _decodeHtmlEntities(json['embed']?.toString() ?? '');
    final source = RegExp(r'''src=["']([^"']+)''').firstMatch(embed);
    return MatchVideo(
      title: json['title']?.toString() ?? 'Video oficial',
      embedUrl: source?.group(1)?.replaceAll('&amp;', '&') ?? '',
    );
  }
}

String _decodeHtmlEntities(String value) {
  return value
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&');
}

class DemoMatches {
  static List<FootballMatch> forType(FeedType type) {
    if (type == FeedType.live) {
      return const [
        FootballMatch(
          title: 'Atlético Nacional - Millonarios',
          competition: 'COLOMBIA: Liga BetPlay',
          date: null,
          thumbnailUrl: '',
          homeTeam: 'Atlético Nacional',
          awayTeam: 'Millonarios',
          matchViewUrl: '',
          videos: [],
        ),
      ];
    }
    return [
      FootballMatch(
        title: 'Barcelona - Real Madrid',
        competition: 'ESPAÑA: LaLiga',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        thumbnailUrl: '',
        homeTeam: 'Barcelona',
        awayTeam: 'Real Madrid',
        matchViewUrl: '',
        videos: const [],
      ),
      FootballMatch(
        title: 'Liverpool - Manchester City',
        competition: 'INGLATERRA: Premier League',
        date: DateTime.now().subtract(const Duration(days: 4)),
        thumbnailUrl: '',
        homeTeam: 'Liverpool',
        awayTeam: 'Manchester City',
        matchViewUrl: '',
        videos: const [],
      ),
      FootballMatch(
        title: 'Inter - Juventus',
        competition: 'ITALIA: Serie A',
        date: DateTime.now().add(const Duration(days: 1)),
        thumbnailUrl: '',
        homeTeam: 'Inter',
        awayTeam: 'Juventus',
        matchViewUrl: '',
        videos: const [],
      ),
    ];
  }
}

String formatMatchDate(DateTime? date) {
  if (date == null) return 'Por confirmar';
  final local = date.toLocal();
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${local.day} ${months[local.month - 1]} · ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
