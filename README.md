# aidentify_endoapp (Flutter Frontend)

AIdentify EndoApp — Flutter frontend for the AIdentify healthcare platform.

This app implements a two-page diagnostic flow (Patient History → Clinical & Radiographic) with rule-based etiology filtering. It talks to the Django REST API via JWT and supports secure media uploads.

## Highlights
- Cross‑platform: Web (primary), plus Android/iOS/Desktop during development as needed.
- MVC-like structure: **screens** (UI), **widgets** (reusable UI), **services** (API/auth/storage).
- JWT auth with automatic refresh; web storage sync supported.
- Real image/file uploads to backend `/media/` endpoints.
- Diagnosis engine screens driven by structured questions.

## Tech
- Dart >=3.x / Flutter >=3.x
- State management: (controller/service pattern)
- HTTP via `http`/`dio` (see `services/`)
- Secure storage (web: `localStorage`, mobile/desktop: secure storage abstraction)

## Project Structure (convention)
```
lib/
  config/           # env & constants (API base URL via --dart-define)
  screens/          # page UIs (Page 1 & Page 2 w/ navigation)
  widgets/          # shared components
  services/         # ApiClient, AuthService (JWT), UploadService
  models/           # DTOs (Patient, VisitHistory, ResearchPaper, etc.)
  diagnosis/        # engine helpers, question models
  main.dart
assets/
```

## API Endpoints (expected)
- `POST /api/token/` → obtain JWT
- `POST /api/token/refresh/` → refresh JWT
- CRUD resources: `/api/patients/`, `/api/visits/`, `/api/research-papers/`, `/api/notifications/`
- Media: `/media/...` served by backend (authenticated uploads)

## Environment
We use **compile-time** env via Dart defines. Example dev values:
```
flutter run -d chrome
```
Optional:
- `WEB_STORAGE_KEY=jwt_pair` (storage key for web multi-tab syncing).

## JWT Notes
- Access + Refresh tokens stored securely (web: `localStorage`). 
- Auto-refresh on 401; if refresh fails, user is logged out.
- Multi-tab sync on web via the `storage` event.

## Scripts
- `flutter pub get`
- `flutter analyze`
- `flutter format .`
- `flutter test` (add tests under `test/`)

## Web Build
```
flutter build web --release
```
Serve `build/web/` behind HTTPS with proper CORS from backend.

## Contributing
- Keep widgets stateless where possible.
- Put all network calls in `services/` and keep screens dumb.
- One responsibility per file; small controllers over fat widgets.
