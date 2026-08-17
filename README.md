# Intelligent Notebook

A smart notebook app built with Flutter — notes, canvas, calendar, and AI chat.

## Features

- **Notebooks & Notes** — Create, edit, and organize notes with rich text and blocks
- **Canvas** — Draw with stylus/pen support, pressure sensitivity, undo/redo
- **Calendar** — Integrated with Google Calendar for event management
- **AI Chat** — Ask questions, attach notes/drawings as context, get AI-powered answers

## Architecture

Feature-first architecture with clean separation:

```
lib/
├── core/                    # Shared across all features
│   ├── di/                  # Dependency injection (GetIt)
│   ├── theme/               # App theme (light/dark)
│   ├── routes/              # GoRouter configuration
│   ├── utils/               # Constants, formatters, validators
│   └── widgets/             # Shared widgets (cards, loading, error, etc.)
│
└── features/
    ├── auth/                # Authentication (Google Sign-In)
    │   ├── data/            # Models, datasources, repositories
    │   ├── domain/          # Entities, repositories, usecases
    │   └── presentation/    # Providers, screens, widgets
    │
    ├── notebooks/           # Notes and notebooks
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── canvas/              # Drawing canvas
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── calendar/            # Google Calendar integration
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    └── chat/                # AI chat with Gemini
        ├── data/
        ├── domain/
        └── presentation/
```

Each feature follows the **data / domain / presentation** pattern:
- **data** — models (DTOs), datasources (Firebase, Hive, APIs), repository implementations
- **domain** — pure entities, repository interfaces, use cases
- **presentation** — Riverpod providers, screens, widgets

## Tech Stack

- **Flutter** — Cross-platform UI framework
- **Firebase** — Firestore (database), Auth, Storage
- **Hive** — Local offline cache
- **Riverpod** — State management
- **GoRouter** — Navigation
- **Google APIs** — Calendar integration
- **Gemini API** — AI chat (via Cloud Functions)

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+
- Firebase project
- Google Cloud project (for Gemini API)

### Setup

1. **Clone and install dependencies:**
   ```bash
   cd intelligent_notebook
   flutter pub get
   ```

2. **Firebase setup:**
   ```bash
   flutterfire configure
   ```

3. **Generate Hive adapters:**
   ```bash
   dart run build_runner build
   ```

4. **Generate `.si` Icon Assets (`jovial_svg`):**
   Convert SVG source files from `assets/icons/svg/` to `.si` binary assets in `assets/icons/`:
   ```bash
   # Convert icons from assets/icons/svg (default) to assets/icons/
   ./scripts/generate_si.sh

   # Or specify a custom source directory:
   ./scripts/generate_si.sh path/to/svg_icons
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

## SVG Icons & Asset Optimization

This app uses [`jovial_svg`](https://pub.dev/packages/jovial_svg) to convert SVG files into binary `.si` files:
- **Source Files Maintained:** Raw `.svg` files are kept in `assets/icons/svg/` in the repository as the source for future edits.
- **Excluded from App Bundle:** `pubspec.yaml` only loads `assets/icons/` (`.si` files), so raw `.svg` files are NOT included in the app bundle, minimizing bundle size.
- **Fast Loading:** `.si` binary files load ~5x to 20x faster than parsing XML at runtime.
- **Dynamic Color Tinting:** Tools like Pencil and Highlighter automatically use filled icons (`pencil-filled.si` and `highlighter-filled.si`) filled with the active selected color when active in the toolbar.

## Configuration

### Firebase
- Create a Firebase project at https://console.firebase.google.com/
- Add Android/iOS/Web apps
- Enable Authentication (Google Sign-In)
- Enable Firestore Database
- Enable Storage

### Google Calendar API
- Go to https://console.cloud.google.com/
- Enable Google Calendar API
- Create OAuth 2.0 credentials
- Add `https://www.googleapis.com/auth/calendar` scope

### Gemini API
- Get an API key from https://aistudio.google.com/
- For production, proxy through Firebase Cloud Functions to hide the key

## Free Tier Limits

| Service | Free Tier |
|---|---|
| Firebase Auth | 10,000 users/month |
| Firestore | 1 GiB storage, 50K reads/day |
| Firebase Storage | 5 GiB |
| Cloud Functions | 2M invocations/month |
| Gemini API | 15 RPM, 1M tokens/month |
| Google Calendar API | 10,000 requests/day |

## License

MIT
