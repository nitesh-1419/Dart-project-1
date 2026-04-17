class WebMapTileConfig {
  static const String providerName = String.fromEnvironment(
    'WEB_TILE_PROVIDER_NAME',
    defaultValue: 'OpenStreetMap',
  );

  static const String urlTemplate = String.fromEnvironment(
    'WEB_TILE_URL_TEMPLATE',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const String fallbackUrl = String.fromEnvironment(
    'WEB_TILE_FALLBACK_URL_TEMPLATE',
    defaultValue: '',
  );

  static const String attributionLabel = String.fromEnvironment(
    'WEB_TILE_ATTRIBUTION',
    defaultValue: 'Map data: OpenStreetMap contributors',
  );

  static const String userAgentPackageName = String.fromEnvironment(
    'WEB_TILE_USER_AGENT_PACKAGE',
    defaultValue: 'com.example.uber_clone',
  );

  static const String apiKey = String.fromEnvironment(
    'WEB_TILE_API_KEY',
    defaultValue: '',
  );

  static const String apiKeyPlaceholder = String.fromEnvironment(
    'WEB_TILE_API_KEY_PLACEHOLDER',
    defaultValue: 'apiKey',
  );

  static const String subdomainsCsv = String.fromEnvironment(
    'WEB_TILE_SUBDOMAINS',
    defaultValue: '',
  );

  static const String statusMessage = String.fromEnvironment(
    'WEB_TILE_STATUS_MESSAGE',
    defaultValue:
        'Development tiles in use. For production, switch WEB_TILE_URL_TEMPLATE to your own hosted provider or self-hosted tiles.',
  );

  static const int maxNativeZoom = int.fromEnvironment(
    'WEB_TILE_MAX_NATIVE_ZOOM',
    defaultValue: 19,
  );

  static bool get isUsingDevelopmentFallback =>
      urlTemplate.contains('tile.openstreetmap.org') && apiKey.isEmpty;

  static bool get hasFallbackUrl => fallbackUrl.isNotEmpty;

  static List<String> get subdomains => subdomainsCsv
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();

  static Map<String, String> get additionalOptions => apiKey.isEmpty
      ? const <String, String>{}
      : <String, String>{apiKeyPlaceholder: apiKey};
}
