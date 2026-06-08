class FanLiveConfig {
  const FanLiveConfig._();

  static const aiProxyBaseUrl = String.fromEnvironment(
    'FANLIVE_AI_PROXY_URL',
    defaultValue: 'http://localhost:3000',
  );

  static Uri aiProxyEndpoint(String path) {
    final baseUri = Uri.parse(aiProxyBaseUrl);
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    return baseUri.replace(
      path: [
        if (baseUri.path.isNotEmpty) baseUri.path.replaceAll(RegExp(r'/$'), ''),
        normalizedPath,
      ].where((part) => part.isNotEmpty).join('/'),
    );
  }
}
