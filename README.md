# Mi-Dine

> Eat out with confidence. A medical dietary passport that tells the kitchen exactly what you cannot eat.

## Overview

Mi-Dine is a Flutter mobile app that turns a diner's medical dietary restrictions into a clear, standardised Kitchen Ticket in the chef's language, and checks restaurant menus against the diner's profile.

## Problem

People with severe food allergies, coeliac disease or chronic gut conditions face real risk when eating out. A server says "the pasta is gluten-free" without knowing the same tongs touched wheat pasta. Technical terms such as cross-contamination are lost in translation when travelling. Menus list main ingredients, not sub-ingredients, so hidden soy, butter or nuts go unnoticed.

## Target Users

- People with anaphylactic allergies (peanuts, tree nuts, shellfish, sesame)
- People with coeliac disease or serious intolerances (gluten, dairy, soy)
- Travellers and expatriates dining where they do not speak the language
- Parents of children with allergies

## Existing Situation

Diners explain verbally to a busy server, carry a printed card, or rely on a restaurant's generic allergen icons. These are inconsistent, easily misheard, rarely in the kitchen's language, and say nothing about preparation (shared fryers, utensils, surfaces).

## Proposed Solution

1. The diner builds a granular medical profile: each trigger plus a severity (Anaphylactic, Severe intolerance, Preference).
2. Mi-Dine generates a **Kitchen Ticket** with strict preparation protocols in English, Spanish, French, Arabic or Mandarin, to show full screen or share.
3. The diner scans a restaurant's QR code and every dish is labelled **Safe, Caution or Not safe**, with the reason.
4. Diners post safety-focused reviews (dedicated fryer, knowledgeable staff).

## Download APK (Direct Link)

[Download Android APK] https://github.com/SHUKURU-K26/mi-dine/releases/download/v1.0.0/app-arm64-v8a-release.apk

Install steps: open the link on an Android phone, download the file, allow "install from unknown sources" if asked, and open it. Requires Android 6.0 or newer and an internet connection.

## Key Features

- Email sign-up and sign-in, Google sign-in, input validation, friendly error messages
- Animated splash and 3-page onboarding
- Medical profile with 9 allergens and 3 severity levels (full create, read, update, delete)
- Kitchen Ticket in 5 languages (including right-to-left Arabic), full-screen chef mode, copy and share
- Restaurant search, cuisine filter, QR scan with manual code fallback
- Per-dish safety assessment with reasons
- Safety reviews with ratings and kitchen-practice tags
- Light and dark mode (system, light or dark), saved on the device
- Skeleton loaders, empty states, error states with retry, success feedback, confirmation dialogs
- Account deletion

## Screenshots & App Icon

| Icon | Home | Profile | Ticket |
|---|---|---|---|
| <img src="docs/screenshots/app-icon.png" width="90"> | <img src="docs/screenshots/03-home.png" width="170"> | <img src="docs/screenshots/04-profile.png" width="170"> | <img src="docs/screenshots/06-ticket.png" width="170"> |

| Arabic ticket | Menu safety | Reviews | Dark mode |
|---|---|---|---|
| <img src="docs/screenshots/07-ticket-arabic.png" width="170"> | <img src="docs/screenshots/09-menu-safety.png" width="170"> | <img src="docs/screenshots/10-reviews.png" width="170"> | <img src="docs/screenshots/11-dark-home.png" width="170"> |

More: onboarding, login, explore and settings are in `docs/screenshots/`.

## UI/UX Design

Design direction, user flow and wireframes are in [`docs/DESIGN.md`](docs/DESIGN.md). Palette comes from the logo (deep teal), with green, amber and red reserved for safety meaning. Poppins and Inter typography, Cupertino icons, 8 pt spacing, responsive layouts that centre and constrain width on large screens.

## Tech Stack

- Flutter, Dart
- Riverpod (`flutter_riverpod`)
- Supabase (PostgreSQL, Auth, auto-generated REST API) via `supabase_flutter`
- `mobile_scanner` (QR), `share_plus`, `shared_preferences`, `google_fonts`, `flutter_dotenv`
- `flutter_launcher_icons`, `image` (icon generation script)

## Architecture

```
UI (screens, widgets)
   |  watches / calls
State (Riverpod providers and notifiers)
   |
Repository (all API calls)
   |
Supabase client (HTTP / JSON)
   |
PostgreSQL with Row Level Security
```

Pure logic (`SafetyChecker`, `TicketBuilder`) is plain Dart with no UI or network, so it is unit-tested.

## State Management

Riverpod was chosen because `AsyncValue` gives loading, data and error states for free, providers are testable without widgets, and `ref.watch` limits rebuilds to the widgets that depend on a value.

| State | Kind | Provider |
|---|---|---|
| Session and user id | Shared, remote | `sessionProvider`, `currentUserIdProvider` |
| My allergens | Shared, remote (`AsyncNotifier`) | `myAllergensProvider` |
| Ticket language | Shared, remote, optimistic update with rollback | `ticketLanguageProvider` |
| Kitchen Ticket | Derived (recomputed from allergens, language, name) | `kitchenTicketProvider` |
| Search text, cuisine filter | Shared UI state | `restaurantSearchProvider`, `cuisineFilterProvider` |
| Filtered restaurants | Derived | `filteredRestaurantsProvider` |
| Theme mode, onboarding done | Device-local (`SharedPreferences`) | `themeModeProvider`, `onboardingProvider` |
| Form fields, password visibility, "safe only" switch | Local widget state | `StatefulWidget` |

## Backend & API

Supabase provides PostgreSQL, authentication and a REST API over each table. Security is enforced by Row Level Security: users can only read or change their own allergens and delete their own reviews. Tables: `profiles`, `allergens`, `user_allergens`, `restaurants`, `dishes`, `reviews`.

## API Endpoints

Base URL: `https://<project>.supabase.co`. All data calls send the user's JWT.

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/auth/v1/signup` | Create account |
| POST | `/auth/v1/token?grant_type=password` | Sign in |
| GET | `/auth/v1/authorize?provider=google` | Google sign-in |
| GET | `/rest/v1/allergens?order=name` | Allergen catalogue |
| GET | `/rest/v1/user_allergens?select=id,severity,allergens(id,name)` | My saved allergens |
| POST | `/rest/v1/user_allergens` (upsert) | Add an allergen or change its severity |
| DELETE | `/rest/v1/user_allergens?user_id=eq.{id}&allergen_id=eq.{id}` | Remove an allergen |
| GET | `/rest/v1/profiles?select=preferred_language` | Read ticket language |
| PATCH | `/rest/v1/profiles?id=eq.{id}` | Update ticket language |
| GET | `/rest/v1/restaurants` | List restaurants |
| GET | `/rest/v1/restaurants?qr_code=eq.{code}` | Find restaurant from QR code |
| GET | `/rest/v1/dishes?restaurant_id=eq.{id}` | Menu of a restaurant |
| GET | `/rest/v1/reviews?select=*,profiles(full_name)&restaurant_id=eq.{id}` | Reviews with author names |
| POST | `/rest/v1/reviews` | Post a review |
| DELETE | `/rest/v1/reviews?id=eq.{id}` | Delete own review |
| POST | `/rest/v1/rpc/delete_my_account` | Delete the signed-in account |

## Project Structure

```
lib/
├── core/
│   ├── constants/   ticket_templates.dart
│   ├── theme/       app_colors, app_palette, app_theme, severity_style, safety_style
│   └── utils/       validators.dart, error_text.dart
├── models/          allergen, severity, user_allergen, dish, restaurant, review, kitchen_ticket, dish_assessment
├── services/        safety_checker.dart, ticket_builder.dart
├── repositories/    auth_repository, profile_repository, restaurant_repository
├── state/           auth, profile, ticket, restaurant, navigation, onboarding, theme providers and controllers
├── screens/         splash, onboarding, auth, shell, home, profile, ticket, restaurants, reviews
├── widgets/         reusable components (text field, loading button, skeleton, empty/error states, glass container...)
├── app.dart
└── main.dart
tool/make_icon.dart  generates the launcher icon source from the logo
docs/                design documentation and screenshots
test/                unit tests
```

## Installation & Setup

```bash
git clone https://git.nexventures.net/nexventures/finalizma.git
cd finalizma
git checkout final/shukuru-kamanzi
flutter pub get
```

1. Create a free project at supabase.com.
2. In its SQL Editor, run the schema, seed data and functions listed in `docs/supabase.sql` (see Known Limitations).
3. Create `.env` from the example and fill it in.
4. `flutter run`

## Building the APK

```bash
flutter build apk --release --split-per-abi
```

Output: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.

## Environment Variables

Copy `.env.example` to `.env`:

| Variable | Meaning |
|---|---|
| `SUPABASE_URL` | Project URL from Supabase, Project Settings, API |
| `SUPABASE_ANON_KEY` | The publishable (anon) key. Never use the secret or service_role key |

`.env` is git-ignored. It is bundled as an asset so the release APK can reach Supabase. The publishable key is safe to ship because Row Level Security protects the data.

## Running the Application

```bash
flutter run                 # connected device or emulator
flutter run -d chrome       # quick UI development (camera and Google sign-in need Android)
```

## Testing

```bash
flutter test
flutter analyze
```

Unit tests cover the dish safety rules (anaphylactic, severe and preference severities, traces, sorting).

## Git Branch

Submission branch: `final/shukuru-kamanzi`

## Known Limitations

- Ticket translations were written by the developer and should be reviewed by native speakers before real-world use.
- Menu and ingredient data is seeded. A real product needs restaurants to maintain their own menus.
- Mi-Dine is a communication aid, not a medical authority, and cannot guarantee a meal is safe.
- No OCR menu scanning, doctor verification or map in this MVP.
- Google sign-in works on Android only. iOS builds were out of scope.

## Future Improvements

- OCR scanner for paper menus with AI risk flagging
- Doctor or lab verification badge
- Safe-dining community map
- Restaurant dashboard to manage menus and ingredients
- Push notifications and offline ticket cache
- Native-speaker reviewed translations and more languages

## Author

Shukuru Kamanzi, Nexventures Flutter Masterclass final challenge.