# Fútbol al día

Aplicación Flutter para consultar partidos y videos oficiales de ScoreBat. Incluye buscador, filtros de destacados/directos, historial de los elementos recibidos y una ficha de partido que abre estadísticas y videos en una WebView.

## Ejecutar

```bash
flutter pub get
flutter run
```

Sin token, la aplicación inicia en **modo demo** para que la interfaz pueda revisarse sin credenciales.

## Conectar ScoreBat

Solicita un token en ScoreBat y ejecútala sin escribirlo en el código:

```bash
flutter run --dart-define=SCOREBAT_TOKEN=tu_token
```

El feed gratuito usa `free-feed`. Los directos y otros endpoints pueden requerir un plan de ScoreBat compatible con tu token. En producción, protege el token con un backend propio: los valores incluidos en una aplicación móvil distribuida se pueden extraer.

## Plataformas

La reproducción y la ficha de estadísticas usan `webview_flutter`; ejecútala en Android, iOS o macOS para abrir esos contenidos. Android ya declara el permiso de Internet requerido.
