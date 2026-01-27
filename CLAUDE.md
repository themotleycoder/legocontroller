# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter mobile application for controlling LEGO Powered Up train hubs and switch hubs via Bluetooth LE. The app communicates with a backend web service (Python server, URL configured via environment variables) that handles the actual Bluetooth connections to LEGO devices. Features include manual train/switch control and self-driving trains.

## Common Commands

### Development
```bash
# Install dependencies (including local universal_ble package)
flutter pub get

# Run the app in debug mode
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Generate code for freezed models (after modifying models)
flutter pub run build_runner build --delete-conflicting-outputs

# Generate launcher icons
flutter pub run flutter_launcher_icons
```

### Building
```bash
# Build for Android
flutter build apk --release
flutter build appbundle --release  # For Play Store

# Build for iOS (requires macOS)
flutter build ios --release

# Clean build artifacts
flutter clean
```

### Testing
```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## Architecture

### State Management
Uses Provider pattern with two main providers:
- `TrainStateProvider`: Manages connected trains, polls backend for status updates, tracks speed/direction locally, includes error state
- `SwitchStateProvider`: Manages connected switches, polls backend for switch positions, includes error state

All providers are configured in `main.dart` using `MultiProvider`.

### Backend Communication
`TrainWebService` (singleton) handles all HTTP communication with the Python backend:
- **Train control**: POST to `/train` with `hub_id` and `power` (-100 to 100)
- **Switch control**: POST to `/switch` with `hub_id`, `switch` name (A/B/C), and `position` (STRAIGHT/DIVERGING)
- **Self-drive mode**: POST to `/selfdrive` with `hub_id` and `self_drive` (0/1)
- **Status polling**: GET `/connected/trains` and `/connected/switches`
- **Disconnect**: POST to `/reset` to reset all Bluetooth connections

The backend URL is configured via environment variables (`.env` file). The service loads configuration on initialization using `flutter_dotenv`.

### Environment Configuration
Configuration is managed via `.env` file:
- `BACKEND_URL`: Backend server URL (default: `http://192.168.86.39:8000`)
- `REQUEST_TIMEOUT_SECONDS`: HTTP request timeout in seconds (default: 5)
- `POLL_INTERVAL_SECONDS`: Status polling interval in seconds (default: 1)

The `.env` file is loaded in `main.dart` before the app initializes. All providers and services read from `dotenv.env`.

### Data Models
Uses freezed for immutable models with JSON serialization:
- `TrainStatus`/`Train`: Backend status, includes speed, direction, RSSI, selfDrive flag
- `SwitchStatus`/`Switch`: Switch positions, states, port connections
- `TrainCommand`: Enum for control commands
- All models have `.freezed.dart` and `.g.dart` generated files

### UI Structure
- `HomeScreen`: Tab navigation (trains/switches), orientation-aware layout (landscape uses sidebar, portrait uses bottom nav)
- `TrainScreen`: Grid of connected trains with speed sliders and direction controls, error display for connection issues
- `SwitchScreen`: Grid of connected switches with position buttons, error display for connection issues

### Platform-Specific Notes
- **iOS**: Uses CocoaPods for dependencies, requires Bluetooth permissions in Info.plist, minimum iOS 15.0
- **Android**: Requires Bluetooth permissions in AndroidManifest.xml
- **Orientation**: Supports landscape and portrait, app enforces orientations in `main.dart` via `SystemChrome.setPreferredOrientations`
- **Local dependency**: Uses local `universal_ble` package from `../universal_ble` (not pub.dev version)

### Key Patterns
- Polling interval: Configurable via environment variable (default 1 second)
- Provider updates: Call `notifyListeners()` only when state changes to avoid unnecessary rebuilds
- Error handling: Services throw custom exceptions (`TrainWebServiceException`), providers track error state, UI displays error views with retry buttons
- Environment configuration: All configuration via `.env` file loaded at app startup
