# LEGO Controller

A Flutter mobile application for controlling LEGO Powered Up train hubs and switch hubs via Bluetooth LE. The app provides manual control and self-driving capabilities for LEGO trains.

## Features

- **Train Control**: Manual control of LEGO train speed and direction
- **Switch Control**: Control track switches for route selection
- **Self-Drive Mode**: Automated train operation
- **Real-time Status**: Live monitoring of connected devices, speed, direction, and signal strength
- **Multi-Device Support**: Control multiple trains and switches simultaneously
- **Responsive UI**: Adaptive layout for portrait and landscape orientations

## Requirements

### Software
- Flutter SDK 3.5.4 or higher
- Dart SDK (included with Flutter)
- iOS 15.0+ or Android (for deployment)
- Xcode 14+ (for iOS development, macOS only)
- CocoaPods (for iOS dependencies)

### Hardware
- LEGO Powered Up train hubs
- LEGO Technic hubs (for switches)
- Backend server running on local network (Python server at `192.168.86.39:8000`)

## Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd legocontroller
```

### 2. Install Dependencies
```bash
# Install Flutter dependencies (including local universal_ble package)
flutter pub get

# For iOS, install CocoaPods dependencies
cd ios
pod install
cd ..
```

### 3. Configure Environment Variables
Create a `.env` file in the project root (use `.env.example` as template):
```bash
BACKEND_URL=http://192.168.86.39:8000
REQUEST_TIMEOUT_SECONDS=5
POLL_INTERVAL_SECONDS=1
```
Update `BACKEND_URL` to match your backend server's IP address.

## Building

### iOS
```bash
# Build for iOS device
flutter build ios --release

# Or run directly on connected device/simulator
flutter run
```

**iOS Requirements:**
- Minimum deployment target: iOS 15.0
- Permissions required: Bluetooth
- HTTP exception configured for local backend server

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

## Development

### Running the App
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode with hot reload
flutter run
```

### Code Generation
The app uses `freezed` and `json_serializable` for model classes. After modifying models, regenerate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Updating Launcher Icons
After modifying `assets/icon/app_icon.png`:
```bash
flutter pub run flutter_launcher_icons
```

## Architecture

### State Management
- **Provider pattern** with two main providers:
  - `TrainStateProvider`: Manages train connections, polls backend every second
  - `SwitchStateProvider`: Manages switch connections and positions

### Backend Communication
- REST API communication via `TrainWebService` singleton
- Endpoints:
  - `POST /train` - Control train speed/direction
  - `POST /switch` - Control switch position
  - `POST /selfdrive` - Toggle self-drive mode
  - `GET /connected/trains` - Get train status
  - `GET /connected/switches` - Get switch status
  - `POST /reset` - Reset Bluetooth connections

## Configuration

### Environment Variables
The app uses environment variables configured in `.env` file:
- `BACKEND_URL`: Backend server URL (default: `http://192.168.86.39:8000`)
- `REQUEST_TIMEOUT_SECONDS`: HTTP request timeout (default: 5)
- `POLL_INTERVAL_SECONDS`: Status polling interval (default: 1)

### iOS Permissions
Configured in `ios/Runner/Info.plist`:
- **NSBluetoothAlwaysUsageDescription**: LEGO hub communication
- **NSBluetoothPeripheralUsageDescription**: LEGO hub communication

### iOS Deployment Target
- Minimum: iOS 15.0
- Platform set in `ios/Podfile`: `platform :ios, '15.0'`

## Troubleshooting

### Blank Screen on iOS
1. Ensure backend server is running on `192.168.86.39:8000`
2. Verify phone is on the same network as backend
3. Check HTTP permissions in Info.plist
4. Test backend connectivity: open `http://192.168.86.39:8000` in Safari

### Build Errors
```bash
# Clean build artifacts
flutter clean

# For iOS, also clean pods
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Rebuild
flutter build ios
```

### Bluetooth Connection Issues
- Verify LEGO hubs are powered on
- Check backend server logs
- Try resetting Bluetooth via app (disconnect all)

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models (freezed)
│   ├── train_status.dart
│   ├── switch_status.dart
│   └── train_command.dart
├── providers/                         # State management
│   ├── train_state_provider.dart
│   └── switch_state_provider.dart
├── screens/                           # UI screens
│   ├── home-screen.dart
│   ├── train-screen.dart
│   └── switch-screen.dart
├── services/                          # Business logic
│   └── lego-webservice.dart
├── widgets/                           # Reusable UI components
└── style/                             # App styling

ios/                                   # iOS-specific code
android/                               # Android-specific code
assets/                                # Images and resources
```

## Dependencies

### Main Dependencies
- `flutter`: SDK
- `provider`: State management
- `universal_ble`: Bluetooth Low Energy (local package)
- `http`: HTTP client for backend API
- `google_fonts`: Typography
- `flutter_dotenv`: Environment variable management
- `freezed`: Code generation for models
- `json_serializable`: JSON serialization

### Dev Dependencies
- `build_runner`: Code generation
- `flutter_lints`: Code analysis
- `flutter_launcher_icons`: Icon generation

## Notes

- The app uses a **local** `universal_ble` package from `../universal_ble`
- Backend server must be running for the app to function
- Train names are dynamically loaded from backend metadata
- All state updates use polling (configurable interval, default 1 second)
- Configuration is managed via `.env` file for easy environment switching

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contributing

[Add contribution guidelines here]
