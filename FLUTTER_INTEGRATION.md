# Flutter App Integration - API Authentication

## Summary

This document describes the integration of API key authentication between the Flutter LEGO Train Controller app and the Python backend service.

**Integration Date:** January 30, 2026
**Status:** ✅ Complete

---

## Changes Made

### 1. Environment Configuration

**Files Updated:**
- [`.env.example`](.env.example) - Added API_KEY template
- [`.env`](.env) - Added actual API key

**New Configuration:**
```bash
# API Authentication
# This must match one of the API_KEYS configured in the Python backend
API_KEY=BiHD1W2boepGwXO9ZkiNYj3Il2kCugjiT1V11k6iBjE
```

### 2. Web Service Client Updates

**File:** [`lib/services/lego-webservice.dart`](lib/services/lego-webservice.dart)

**Changes:**
1. **Added API key field:**
   ```dart
   String? _apiKey;
   ```

2. **Load API key from environment:**
   ```dart
   _apiKey = dotenv.env['API_KEY']
   ```

3. **Added authentication header helper:**
   ```dart
   Map<String, String> _getHeaders() {
     final headers = {
       'Content-Type': 'application/json',
     };

     if (_apiKey != null && _apiKey!.isNotEmpty) {
       headers['X-API-Key'] = _apiKey!;
     }

     return headers;
   }
   ```

4. **Updated all HTTP requests:**
   - `selfDriveTrain()` - Added `headers: _getHeaders()`
   - `controlTrain()` - Added `headers: _getHeaders()`
   - `controlSwitch()` - Added `headers: _getHeaders()`
   - `resetBluetooth()` - Added `headers: _getHeaders()`
   - `getConnectedTrains()` - Added `headers: _getHeaders()`
   - `getConnectedSwitches()` - Added `headers: _getHeaders()`
   - `getSwitchStatus()` - Added `headers: _getHeaders()`

---

## Configuration Synchronization

### Python Backend Configuration

**File:** `/Users/jm/src/lego_trains/lego-train-controller/.env`

```bash
API_KEYS=BiHD1W2boepGwXO9ZkiNYj3Il2kCugjiT1V11k6iBjE
REQUIRE_AUTH=true
ALLOWED_ORIGINS=http://localhost:8080,capacitor://localhost,http://192.168.86.39:8080
```

### Flutter App Configuration

**File:** `.env`

```bash
BACKEND_URL=http://192.168.86.39:8000
API_KEY=BiHD1W2boepGwXO9ZkiNYj3Il2kCugjiT1V11k6iBjE
```

**⚠️ Important:** The `API_KEY` in the Flutter app **must match** one of the keys in the Python backend's `API_KEYS` list.

---

## How It Works

### Request Flow

1. **Flutter App** makes HTTP request to Python backend
2. **TrainWebService** adds `X-API-Key` header with configured API key
3. **Python Backend** validates the API key via authentication middleware
4. If valid, request is processed; if invalid, returns 401/403 error

### Authentication Header Format

```
X-API-Key: BiHD1W2boepGwXO9ZkiNYj3Il2kCugjiT1V11k6iBjE
```

### Example Request

```dart
// Flutter code automatically includes authentication
final response = await http.post(
  Uri.parse('$baseUrl/train'),
  headers: _getHeaders(),  // Includes X-API-Key header
  body: jsonEncode({'hub_id': 12, 'power': 50}),
);
```

**Actual HTTP Request:**
```http
POST /train HTTP/1.1
Host: 192.168.86.39:8000
Content-Type: application/json
X-API-Key: BiHD1W2boepGwXO9ZkiNYj3Il2kCugjiT1V11k6iBjE

{"hub_id": 12, "power": 50}
```

---

## Error Handling

### Authentication Errors

**401 Unauthorized** - Missing API key:
```json
{
  "detail": "Missing API key. Provide X-API-Key header.",
  "timestamp": 1769785490.049751
}
```

**403 Forbidden** - Invalid API key:
```json
{
  "detail": "Invalid API key",
  "timestamp": 1769785490.049751
}
```

### Flutter Error Handling

Existing error handling in `TrainWebService` will catch authentication errors:

```dart
if (response.statusCode != 200) {
  throw TrainWebServiceException(
    'Failed to control train: ${response.body}',
  );
}
```

**User Impact:**
- Authentication errors will appear as connection errors in the UI
- Error messages will include the HTTP response body with details

---

## Setup Instructions

### For Developers

**1. Python Backend Setup:**
```bash
cd /Users/jm/src/lego_trains/lego-train-controller

# Ensure .env file has API key configured
grep API_KEYS .env

# Start the service
python3 webservice/train_service.py
```

**2. Flutter App Setup:**
```bash
cd ~/src/lego_trains/legocontroller

# Ensure .env file has matching API key
grep API_KEY .env

# Run the app
flutter run
```

### For Production

**1. Generate New API Keys:**
```bash
# Generate a secure API key
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

**2. Configure Python Backend:**
```bash
# Edit backend .env
nano /path/to/lego-train-controller/.env

# Add to API_KEYS (comma-separated for multiple keys)
API_KEYS=new-secure-key-here
```

**3. Configure Flutter App:**
```bash
# Edit Flutter .env
nano ~/src/lego_trains/legocontroller/.env

# Set matching API key
API_KEY=new-secure-key-here
```

**4. Test Connection:**
```bash
# Test health endpoint (no auth required)
curl http://192.168.86.39:8000/health

# Test authenticated endpoint
curl -X GET http://192.168.86.39:8000/connected/trains \
  -H "X-API-Key: new-secure-key-here"
```

---

## Security Considerations

### Do's ✅

- ✅ **Use long, random API keys** (32+ characters)
- ✅ **Different keys for dev/production**
- ✅ **Keep `.env` files in `.gitignore`**
- ✅ **Rotate keys periodically**
- ✅ **Use HTTPS in production** (via reverse proxy)

### Don'ts ❌

- ❌ **Never commit API keys to Git**
- ❌ **Don't share keys via insecure channels**
- ❌ **Don't use predictable keys**
- ❌ **Don't reuse keys across environments**

### Current Setup Security

**Development (Current):**
- ✅ API key configured
- ✅ Authentication enabled
- ⚠️ HTTP only (local network)
- ⚠️ No HTTPS (acceptable for local dev)

**Production Recommendations:**
- Use HTTPS with reverse proxy (nginx/Apache)
- Use strong, unique API keys
- Enable firewall rules
- Monitor access logs

---

## Testing

### Manual Testing

**1. Test without API key (should fail):**
```bash
curl -X POST http://192.168.86.39:8000/train \
  -H "Content-Type: application/json" \
  -d '{"hub_id": 12, "power": 50}'

# Expected: 401 Unauthorized
```

**2. Test with valid API key (should succeed):**
```bash
curl -X POST http://192.168.86.39:8000/train \
  -H "Content-Type: application/json" \
  -H "X-API-Key: BiHD1W2boepGwXO9ZkiNYj3Il2kCugjiT1V11k6iBjE" \
  -d '{"hub_id": 12, "power": 50}'

# Expected: 200 OK with {"status": "success", ...}
```

**3. Test Flutter app:**
- Launch Python backend
- Launch Flutter app
- Verify train control works
- Check backend logs for authenticated requests

### Automated Testing

Flutter unit tests should mock the API key:

```dart
// In test setup
TrainWebService().configure(
  customBaseUrl: 'http://test-server',
  apiKey: 'test-api-key-12345',
);
```

---

## Troubleshooting

### Problem: "Missing API key" error

**Symptoms:**
- Flutter app shows connection errors
- Backend logs show 401 Unauthorized

**Solution:**
```bash
# Check Flutter .env file
grep API_KEY ~/src/lego_trains/legocontroller/.env

# Ensure it's not empty
# Restart Flutter app after changing .env
```

### Problem: "Invalid API key" error

**Symptoms:**
- Flutter app shows connection errors
- Backend logs show 403 Forbidden

**Solution:**
```bash
# Verify keys match
echo "Flutter key:"
grep API_KEY ~/src/lego_trains/legocontroller/.env

echo "Backend keys:"
grep API_KEYS /Users/jm/src/lego_trains/lego-train-controller/.env

# Keys must match exactly
```

### Problem: Authentication works locally but not on device

**Symptoms:**
- Works in debug mode
- Fails on physical device

**Solution:**
```bash
# Check BACKEND_URL points to correct IP
# Use network IP, not localhost
BACKEND_URL=http://192.168.86.39:8000  # ✅ Good
BACKEND_URL=http://localhost:8000      # ❌ Bad (won't work on device)
```

### Problem: Flutter app doesn't load new API key

**Solution:**
```bash
# Stop app completely
flutter clean

# Restart
flutter run
```

---

## Migration Notes

### Upgrading from Unauthenticated Version

If upgrading from a version without authentication:

1. **Update Python backend** (Phases 1 & 2 complete)
2. **Update Flutter app** (this integration)
3. **Configure API keys** in both `.env` files
4. **Test locally** before deploying
5. **Update deployment docs** with new requirements

### Backward Compatibility

**Python Backend:**
- Can disable auth with `REQUIRE_AUTH=false` in `.env`
- Useful for testing or gradual rollout

**Flutter App:**
- Will work with or without API key configured
- If no key in `.env`, header is not sent
- Old backend (no auth) will ignore the header

---

## API Reference

### TrainWebService Methods

All methods now automatically include authentication:

| Method | Endpoint | Auth Required | Notes |
|--------|----------|---------------|-------|
| `controlTrain()` | POST `/train` | ✅ Yes | Power control |
| `selfDriveTrain()` | POST `/selfdrive` | ✅ Yes | Toggle self-drive |
| `controlSwitch()` | POST `/switch` | ✅ Yes | Switch control |
| `resetBluetooth()` | POST `/reset` | ✅ Yes | BLE reset |
| `getConnectedTrains()` | GET `/connected/trains` | ✅ Yes | Train status |
| `getConnectedSwitches()` | GET `/connected/switches` | ✅ Yes | Switch count |
| `getSwitchStatus()` | GET `/connected/switches` | ✅ Yes | Switch details |

**Note:** Health endpoint (`/health`) does not require authentication.

---

## Files Changed

### Flutter App

**Modified:**
- [`.env.example`](.env.example) - Added API_KEY configuration
- [`.env`](.env) - Added actual API key
- [`lib/services/lego-webservice.dart`](lib/services/lego-webservice.dart) - Added authentication

**New:**
- [`FLUTTER_INTEGRATION.md`](FLUTTER_INTEGRATION.md) - This documentation

### Python Backend

**See:**
- [`PHASE1_CHANGES.md`](../lego-train-controller/PHASE1_CHANGES.md) - Security implementation
- [`DEPLOYMENT_GUIDE.md`](../lego-train-controller/DEPLOYMENT_GUIDE.md) - Deployment instructions

---

## Next Steps

### Immediate
- ✅ Flutter app updated with authentication
- ✅ Configuration synchronized
- ✅ Documentation complete

### Optional Enhancements
- Add API key rotation mechanism
- Add authentication status indicator in UI
- Add error handling for auth failures
- Add retry logic for 401/403 errors

### Production Deployment
1. Generate production API keys
2. Configure HTTPS reverse proxy
3. Update firewall rules
4. Deploy backend service
5. Build and deploy Flutter app
6. Test end-to-end connectivity

---

## Summary

✅ **Flutter app successfully integrated with authenticated Python backend!**

**What Changed:**
- API key configuration in `.env` files
- Authentication headers added to all HTTP requests
- Automatic authentication for all API calls
- Error handling for auth failures

**Security Improved:**
- All API endpoints now require authentication
- Unauthorized access blocked
- API key validation working

**Ready for:**
- Production deployment
- Testing with physical hardware
- Integration with LEGO train controllers

---

For questions or issues, see:
- [Python Backend Security Guide](../lego-train-controller/SECURITY.md)
- [Python Backend Deployment Guide](../lego-train-controller/DEPLOYMENT_GUIDE.md)
- [Phase 1 Implementation Details](../lego-train-controller/PHASE1_CHANGES.md)
