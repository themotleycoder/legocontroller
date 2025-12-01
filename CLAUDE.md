# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter mobile application for controlling LEGO Powered Up train hubs and switch hubs via Bluetooth LE. The app communicates with a backend web service (Python server at `http://192.168.86.39:8000`) that handles the actual Bluetooth connections to LEGO devices. Features include manual train/switch control, voice commands, and self-driving trains.

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
Uses Provider pattern with three main providers:
- `TrainStateProvider`: Manages connected trains, polls backend every second for status updates, tracks speed/direction locally
- `SwitchStateProvider`: Manages connected switches, polls backend for switch positions
- `VoiceControlProvider`: Coordinates voice commands, depends on both train and switch providers

All providers are configured in `main.dart` using `MultiProvider`. VoiceControlProvider uses `ChangeNotifierProxyProvider2` to access train and switch providers.

### Backend Communication
`TrainWebService` (singleton) handles all HTTP communication with the Python backend:
- **Train control**: POST to `/train` with `hub_id` and `power` (-100 to 100)
- **Switch control**: POST to `/switch` with `hub_id`, `switch` name (A/B/C), and `position` (STRAIGHT/DIVERGING)
- **Self-drive mode**: POST to `/selfdrive` with `hub_id` and `self_drive` (0/1)
- **Status polling**: GET `/connected/trains` and `/connected/switches`
- **Disconnect**: POST to `/reset` to reset all Bluetooth connections

The backend URL is hardcoded to `192.168.86.39:8000` but can be configured via `configure()` method.

### Voice Control System
Three-layer architecture:
1. `VoiceControlService`: Low-level speech-to-text using `speech_to_text` package, handles microphone permissions, produces command streams
2. `VoiceCommandParser`: Stateless parser that converts natural language to structured commands. Dynamically maps train names from backend metadata (e.g., "red train", "passenger train"). Supports relative speed adjustments ("faster", "slower") by tracking current train state.
3. `VoiceControlProvider`: High-level coordinator that listens to service streams and executes parsed commands via train/switch providers

Voice commands support:
- Train control: "train [id/name] forward/backward [speed]"
- Relative speed: "train [id/name] faster/slower" (adjusts current speed by ±10)
- Switch control: "switch [id] straight/diverging/left/right"
- Self-drive: "self drive train [id] on/off"
- Emergency stop: "stop all/everything"

### Data Models
Uses freezed for immutable models with JSON serialization:
- `TrainStatus`/`Train`: Backend status, includes speed, direction, RSSI, selfDrive flag
- `SwitchStatus`/`Switch`: Switch positions, states, port connections
- `TrainCommand`: Enum for control commands
- All models have `.freezed.dart` and `.g.dart` generated files

### UI Structure
- `HomeScreen`: Tab navigation (trains/switches), orientation-aware layout (landscape uses sidebar, portrait uses bottom nav)
- `TrainScreen`: Grid of connected trains with speed sliders and direction controls
- `SwitchScreen`: Grid of connected switches with position buttons
- Voice control FAB available on both screens, shows listening state overlay

### Platform-Specific Notes
- **iOS**: Uses CocoaPods for dependencies, requires microphone permission in Info.plist
- **Android**: Requires microphone and Bluetooth permissions in AndroidManifest.xml
- **Orientation**: Supports landscape and portrait, app enforces landscape/portrait in `main.dart` via `SystemChrome.setPreferredOrientations`
- **Local dependency**: Uses local `universal_ble` package from `../universal_ble` (not pub.dev version)

### Key Patterns
- Polling interval: 1 second for train/switch status
- Provider updates: Call `notifyListeners()` only when state changes to avoid unnecessary rebuilds
- Error handling: Services throw custom exceptions (`TrainWebServiceException`), UI shows snackbars
- Voice confidence threshold: 0.5 minimum confidence for command recognition
