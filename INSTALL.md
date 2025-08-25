# Install & Run — Flutter Frontend

## Prereqs
- Flutter SDK (latest stable)
- Dart SDK (bundled with Flutter)
- Chrome (for web), or platform SDKs for mobile/desktop as needed

Verify:
```
flutter --version
dart --version
```

## Setup
```
flutter pub get
```

## Configure Backend URL
Use Dart defines so builds remain environment-agnostic:
```
# Development
flutter run -d chrome --web-renderer html   --dart-define=API_BASE_URL=http://localhost:8000

# Production
flutter build web --release   --dart-define=API_BASE_URL=https://api.aidentify.app
```

Your `ApiClient` should read `const String.fromEnvironment('API_BASE_URL')`.

## Auth
- Obtain tokens from `/api/token/`.
- Refresh via `/api/token/refresh/`.
- Store both tokens; attach `Authorization: Bearer <access>` to requests.

## Troubleshooting
- **CORS**: Ensure backend `CORS_ALLOWED_ORIGINS` includes your web origin.
- **401 after refresh**: Check system time sync and refresh token validity.
- **Uploads fail**: Confirm `MEDIA_URL`, `MEDIA_ROOT`, and `Content-Type: multipart/form-data`.
