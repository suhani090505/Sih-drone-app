class AppConfig {
  // Set at build time with --dart-define, fallback to a safe default.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://sih-drone-app-2-109e.onrender.com', // your Render URL
  );
}
