# Individual Assignment — Mobile App Development II (SSP Student Version)

## Flutter Mobile Application – SSP Integrated Project (MAD 2)

Student: <YourName>  
Student ID: <YourID>  
Module: COMP50011  
Submission Date: <Date>

---

## Table of Contents

1. Introduction
2. Application Architecture
3. Authentication & API Integration
4. Data Integration (Online/Offline)
5. Scrollable List & Master/Detail Flow
6. Mobile Device Capabilities
7. External State Management (Provider)
8. Testing & Robustness
9. User Interface (UI/UX)
10. Summary & Reflection
11. Appendix / Checklist
12. References

---

## 1. Introduction

Luxe Hair Studio is a premium salon booking application that allows users to discover services, view deals, book appointments by paying a 10% advance, track booking history, manage favorites, and maintain a personal profile. The app targets Android primarily and follows a polished, modern design.

- Built with Flutter and Material 3 theming (see `lib/main.dart`).
- Uses Provider for state management across multiple domains (Auth, Services, Deals, Payments, Bookings, Notifications, Theme).
- Integrates with an SSP Laravel Sanctum API for authentication via `lib/services/auth_service.dart` and `lib/providers/auth_provider.dart` (token stored using `flutter_secure_storage`).
- Also integrates local notifications and FCM-ready hooks via `lib/services/notification_service.dart`.

Technologies:
- Flutter, Dart, Material 3, Google Fonts
- Provider (state management)
- Dio (HTTP client for SSP Sanctum)
- SharedPreferences (local persistence)
- Flutter Secure Storage (secure token storage)
- Firebase Core + Messaging (notifications), flutter_local_notifications
- connectivity_plus, geolocator, google_maps_flutter, url_launcher, image_picker

## 2. Application Architecture

Overview:
- Entry point `main()` initializes Flutter bindings, Firebase (on non-web), and NotificationService, then runs `LuxeHairStudioApp`.
- `MaterialApp` applies light/dark `ThemeData` configured from `LuxeColors` and `LuxeTypography`.
- `MultiProvider` composes core providers: `ThemeProvider`, `AuthProvider`, `BookingProvider`, `ServiceProvider`, `FavoritesProvider`, `BookingHistoryProvider`, `NotificationProvider`, `PaymentProvider`, `DealsProvider` (see `lib/main.dart`).
- Navigation: `MainNavScreen` with a bottom navigation (CurvedNavigationBar) for Home, Services, Booking History, and Profile. Separate routes for Splash, Login, Register.

Layers and relationships:
- UI Screens -> consume Providers via Consumer/Provider.of
- Providers (ChangeNotifier) -> orchestrate data, call Services
- Services -> external APIs (SSP Sanctum via Dio), HTTP (deals), local assets, device features

Key external libraries (from `pubspec.yaml`) and purpose:
- provider: app-wide state
- dio: SSP Sanctum API calls
- flutter_secure_storage: secure token
- shared_preferences: caching favorites/history/transactions
- firebase_core, firebase_messaging, flutter_local_notifications: notifications
- connectivity_plus: network state
- geolocator, google_maps_flutter, url_launcher: location and maps/dialer
- image_picker: profile photo/bank slip capture

## 3. Authentication & API Integration

Implemented files:
- `lib/services/auth_service.dart`: Handles Sanctum login, register, logout, get current user, update profile, upload image. Uses Dio with a base URL from `ApiConfig` and interceptors to attach `Authorization: Bearer <token>`.
- `lib/providers/auth_provider.dart`: UI-facing API. Validates inputs, calls AuthService, stores minimal user data in SharedPreferences for offline display, exposes `isLoggedIn`, `name`, `email`, etc.
- UI: `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart` with clean forms, validation, and error messaging.

Token handling:
- Tokens are stored securely using `flutter_secure_storage` (see `AuthService._tokenKey`).
- Interceptor automatically adds `Authorization` header for subsequent requests.
- On 401, provider clears local auth.

Login/Register flow (pseudocode):
```
User enters email/password
 -> AuthProvider.login() validates
 -> AuthService.login() POST /login
 -> if token -> save to secure storage, fetch user -> update provider -> save to SharedPreferences -> navigate to '/'
 -> else show error
```

SSP Compliance:
- Firebase Core remains for notifications; API auth is handled by SSP Sanctum. This meets SSP requirement as long as SSP endpoints are configured in `ApiConfig`.

## 4. Data Integration (Online/Offline)

Sources:
- Services: `ServiceProvider` fetches from a remote JSON (GitHub raw URL) when online and falls back to `assets/services.json` offline.
- Deals: `DealsService` fetches active deals from a Railway backend (`/api/deals/active`), with mock fallback and caching logic in `DealsProvider`.
- Local persistence: SharedPreferences for favorites (`FavoritesProvider`), booking history (`BookingHistoryProvider`), and payment transactions (`PaymentProvider`).

Example API and fallback:
```
if (isOnline) {
  GET https://raw.githubusercontent.com/SalonKuz/demo/main/services.json
  if 200 -> parse -> services
  else -> load assets/services.json
} else {
  load assets/services.json
}
```

Offline handling:
- All read-heavy features have safe fallbacks and guard rails (no crash when offline). Connectivity is detected via `connectivity_plus` in Deals/Services providers.

## 5. Scrollable List & Master/Detail Flow

- Services list: `lib/screens/services_screen.dart` builds ListView of categorized services with images, price badges, and a detail button.
- Detail view: `lib/screens/service_detail_screen.dart` shows full description, booking policy, date/time slot selection, and navigation to `PaymentScreen`.
- Interaction: Tapping a service opens detail via a custom page transition (`SmoothPageTransitions`).

## 6. Mobile Device Capabilities

- Light/Dark Mode: Full dual theme in `lib/main.dart` with `ThemeProvider`.
- Connectivity Awareness: Implemented via `connectivity_plus` in `DealsProvider` and `ServiceProvider`. UI banners (e.g., `ConnectivityBanner`) show state (see imports in `ProfileScreen`).
- Camera/Image Picker: `image_picker` used in `PaymentScreen` (bank slip) and `ProfileAvatar` (profile photo) component.
- Geolocation and Maps: `ProfileScreen` uses `geolocator` to get current position and `google_maps_flutter` to show salon and user markers, plus `url_launcher` to open Google Maps directions.
- Notifications: `NotificationService` sets up local notifications and FCM listeners, schedules booking reminders 24 hours before appointments.

Runtime permissions and platform configs:
- Android: `android/app/src/main/AndroidManifest.xml` declares INTERNET, CAMERA, READ/WRITE storage, FINE/COARSE LOCATION, CALL_PHONE and query intents for url_launcher.
- iOS: `ios/Runner/Info.plist` includes NSCameraUsageDescription, NSPhotoLibraryUsageDescription, NSLocationWhenInUseUsageDescription, etc.

## 7. External State Management (Provider)

Providers:
- `AuthProvider` (auth state)
- `ThemeProvider` (theme mode)
- `ServiceProvider` (services list with online/offline)
- `DealsProvider` (deals with caching and connectivity fallbacks)
- `FavoritesProvider` (favorites persisted locally)
- `BookingHistoryProvider` (bookings with local persistence and notifications)
- `PaymentProvider` (payment transaction state and validation)
- `NotificationProvider` (UI-level notification state; referenced in PaymentScreen)

Usage pattern:
- `ChangeNotifier` + `Consumer`/`Provider.of` across screens.
- Loading and error states exposed (`isLoading`, `status`, `errorMessage`).

Example (simplified):
```
Consumer<DealsProvider>(
  builder: (context, deals, _) {
    if (deals.isLoading) return CircularProgressIndicator();
    if (deals.hasError) return Text(deals.errorMessage!);
    return DealsGrid(deals.deals);
  },
)
```

## 8. Testing & Robustness

- Input validation: Login/Register forms validate email/password; PaymentScreen validates card number (Luhn), expiry, CVV, and cardholder.
- Error handling: Providers catch network exceptions; DealsProvider provides user-friendly messages and mock fallbacks.
- Online/Offline: Services and Deals check connectivity and use local/mock data on failures.
- Release build: Project uses standard Flutter structure; ensure a signed release is built via `flutter build apk`.
- Tests: No explicit tests found in `test/`. Recommendation: add widget tests for the list and provider logic.

## 9. User Interface (UI/UX)

- Material Design compliance with custom theme, consistent elevation, shape, and colors.
- Typography: GoogleFonts Poppins app-wide; accessible sizes and readable contrasts.
- Components: Curved bottom navigation, cards, badges, hero images, polished transitions (`SmoothPageTransitions`).
- Screenshots: [Insert Home, Services, Service Detail, Payment, Profile, Booking History screenshots here]

## 10. Summary & Reflection

This project strengthened understanding of Flutter app architecture with Provider state management, theming with Material 3, and real-world integrations including SSP Laravel Sanctum authentication, connectivity-aware data loading, local storage, notifications, maps/location, and device capabilities. Future improvements include: migrating services to a unified repository with Hive caching, adding integration tests and CI, enhancing animation polish, integrating real payment gateway APIs, and expanding admin dashboards.

## 11. Appendix / Checklist

| Criterion | Status | Actions/Evidence | Files |
|---|---|---|---|
| Platform, Design, 6+ screens, bottom nav | Confirmed | Material 3 themes; Home/Services/BookingHistory/Profile + Splash/Login/Register | `lib/main.dart`, screens/*, utils/* |
| Real content, assets, readability | Confirmed | Services and images under assets; Poppins typography | `pubspec.yaml`, `assets/images/*`, `screens/services_screen.dart` |
| Authentication via SSP Sanctum | Confirmed | Dio + secure storage; provider integrated; forms with validation | `services/auth_service.dart`, `providers/auth_provider.dart`, `screens/login_screen.dart`, `screens/register_screen.dart` |
| Online data (API/JSON) | Confirmed | Services from remote JSON; Deals from Railway API | `providers/service_provider.dart`, `services/deals_service.dart`, `providers/deals_provider.dart` |
| Offline mode | Confirmed | Fallback to `assets/services.json`; local persistence via SharedPreferences | `providers/service_provider.dart`, `assets/services.json`, various providers |
| Scrollable list + detail | Confirmed | ListView in Services; detail page with booking and payment | `screens/services_screen.dart`, `screens/service_detail_screen.dart` |
| 3+ device capabilities | Confirmed | Location/Maps, Camera/Image Picker, Phone dialer, Notifications | `screens/profile_screen.dart`, `services/notification_service.dart`, `payment_screen.dart` |
| Provider state management | Confirmed | MultiProvider, ChangeNotifier, loading/error states | `lib/main.dart`, providers/* |
| Testing & robustness | Partial | Add tests; verify release build; more error/empty states | `test/` (add), CI (optional) |

## 12. References

- Flutter. 2025. Flutter documentation. Available at: https://docs.flutter.dev [Accessed <Date>].
- Provider. 2025. provider package (pub.dev). Available at: https://pub.dev/packages/provider [Accessed <Date>].
- Dio. 2025. dio package (pub.dev). Available at: https://pub.dev/packages/dio [Accessed <Date>].
- connectivity_plus. 2025. connectivity_plus package (pub.dev). Available at: https://pub.dev/packages/connectivity_plus [Accessed <Date>].
- geolocator. 2025. geolocator package (pub.dev). Available at: https://pub.dev/packages/geolocator [Accessed <Date>].
- google_maps_flutter. 2025. google_maps_flutter package (pub.dev). Available at: https://pub.dev/packages/google_maps_flutter [Accessed <Date>].
- flutter_local_notifications. 2025. Package documentation. Available at: https://pub.dev/packages/flutter_local_notifications [Accessed <Date>].
- SSP Laravel Jetstream/Sanctum. 2025. Laravel Sanctum documentation. Available at: https://laravel.com/docs/sanctum [Accessed <Date>].
- url_launcher, image_picker, shared_preferences, flutter_secure_storage: respective pub.dev package pages.

---

Notes for Export
- File name: MAD2_SSP_Assignment_Report_<YourName>.docx
- Export this Markdown to .docx via Microsoft Word (open .md and Save As .docx) or Pandoc.
