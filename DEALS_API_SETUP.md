# Deals API Integration - Setup Guide

## 🎯 Overview
The app now fetches special deals from your Railway-hosted backend at:
```
https://hair-salon-production.up.railway.app
```

## 🔧 Features Implemented

### ✅ What's Working
- **API Integration**: Fetches deals from `/api/deals/active` endpoint
- **Offline Support**: Shows "Oops you are offline" message when no internet
- **Mock Data**: Falls back to 3 sample deals when API is unavailable
- **Smart Caching**: Caches deals for 30 minutes to reduce API calls
- **Error Handling**: User-friendly messages for different error types
- **Beautiful UI**: Animated deal cards with discount badges and expiry timers
- **State Management**: 5 states - initial, loading, loaded, error, offline

### 📦 Files Created
1. **`lib/models/deal.dart`** - Deal data model with JSON serialization
2. **`lib/services/deals_service.dart`** - HTTP service for API calls
3. **`lib/providers/deals_provider.dart`** - State management with caching
4. **`lib/widgets/deals_section.dart`** - Beautiful deals carousel widget

### 🎨 UI States
- **Loading**: Shows shimmer/skeleton cards
- **Loaded**: Horizontal scrolling deal cards with:
  - Discount badges (e.g., "30% OFF")
  - Expiry timers (e.g., "2 days left")
  - Original vs discounted prices
  - High-quality images
- **Offline**: Orange-themed message with retry button
- **Error**: Red-themed error message with retry button
- **Empty**: Friendly "No deals available" message

## 🔐 API Key Configuration

### Option 1: Hardcode in Service (Quick Testing)
Open `lib/services/deals_service.dart` and update line 11:

```dart
String? _apiKey = 'YOUR_API_KEY_HERE'; // Replace with your actual API key
```

### Option 2: Runtime Configuration (Recommended)
Add this code to set API key at runtime (e.g., in settings screen):

```dart
import 'package:provider/provider.dart';
import '../providers/deals_provider.dart';

// In your settings screen or API key input dialog:
context.read<DealsProvider>().setApiKey('YOUR_API_KEY_HERE');
```

### Option 3: Environment Variables (Production)
1. Create `.env` file in project root:
```env
DEALS_API_KEY=your_actual_api_key_here
```

2. Add `flutter_dotenv` to `pubspec.yaml`:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

3. Update `lib/services/deals_service.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

String? _apiKey = dotenv.env['DEALS_API_KEY'];
```

4. Load in `main.dart`:
```dart
await dotenv.load(fileName: ".env");
```

## 🌐 API Endpoints Expected

The service expects these endpoints on your Railway backend:

### 1. Active Deals (Primary)
```
GET https://hair-salon-production.up.railway.app/api/deals/active
```

**Expected Response Format** (any of these):
```json
// Option A: Direct array
[
  {
    "id": "1",
    "title": "Summer Hair Package",
    "description": "Complete hair treatment",
    "imageUrl": "https://example.com/image.jpg",
    "originalPrice": 5000,
    "discountedPrice": 3500,
    "discountPercentage": 30,
    "validUntil": "2024-12-31T23:59:59Z",
    "category": "Hair Care",
    "isActive": true
  }
]

// Option B: Wrapped in data
{
  "data": [ /* deals array */ ]
}

// Option C: Wrapped in deals
{
  "deals": [ /* deals array */ ]
}
```

### 2. All Deals (Fallback)
```
GET https://hair-salon-production.up.railway.app/api/deals
```

### 3. Health Check
```
GET https://hair-salon-production.up.railway.app/api/health
```

## 🔑 Authentication Headers

The service sends API key in headers (choose one format in your backend):

```http
Authorization: Bearer YOUR_API_KEY
```
**OR**
```http
X-API-Key: YOUR_API_KEY
```

## 🧪 Testing

### Test with Mock Data (No API needed)
The app automatically shows mock deals when:
- No internet connection
- API is unreachable
- API returns errors
- API key not configured

### Test with Real API
1. Get your API key from Railway backend
2. Configure using one of the options above
3. Run the app
4. Home screen will show real deals from API
5. Pull down to refresh

### Manual Refresh
Users can pull down on the deals section to force refresh:
```dart
// This is already implemented in DealsSection widget
RefreshIndicator(
  onRefresh: () => dealsProvider.refreshDeals(),
  child: /* deals content */
)
```

## 📊 Deal Model Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | ✅ | Unique identifier |
| `title` | String | ✅ | Deal title (e.g., "Summer Special") |
| `description` | String | ✅ | Deal description |
| `imageUrl` | String | ✅ | Image URL or asset path |
| `originalPrice` | double | ✅ | Original price before discount |
| `discountedPrice` | double | ✅ | Price after discount |
| `discountPercentage` | int | ✅ | Discount % (0-100) |
| `validUntil` | DateTime | ✅ | Expiry date |
| `category` | String | ❌ | Category (Hair, Skin, etc.) |
| `isActive` | bool | ❌ | Active status (default: true) |

## 🎨 Customization

### Change Cache Duration
Edit `lib/providers/deals_provider.dart` line 14:
```dart
static const _cacheDuration = Duration(minutes: 30); // Change to your preference
```

### Change Mock Deals
Edit `lib/services/deals_service.dart` lines 110-180 to add/modify mock deals.

### Change API Timeout
Edit `lib/services/deals_service.dart` line 42:
```dart
final response = await http.get(uri, headers: headers)
    .timeout(const Duration(seconds: 10)); // Change timeout
```

## 🐛 Troubleshooting

### Deals Not Loading
1. Check internet connection
2. Verify API key is set correctly
3. Check Railway backend is running
4. Open `lib/services/deals_service.dart` - debug logs will show in console
5. Check API response format matches expected structure

### "Unauthorized" Error
- API key is missing or incorrect
- Update API key using `setApiKey()` method

### "Not Found" Error
- Check endpoint URLs in `lib/services/deals_service.dart`
- Verify your Railway backend has `/api/deals/active` endpoint

### Offline Message Always Showing
- Check `connectivity_plus` package is working
- Test with: `flutter run` and check logs
- Ensure Railway backend is accessible

## 📱 User Experience

### What Users See
1. **First Load**: Loading shimmer → Deals appear
2. **No Internet**: Orange offline message with retry button
3. **API Error**: Red error message with retry button
4. **Success**: Beautiful deal cards with animations
5. **Expired Deals**: Automatically filtered out
6. **Expiring Soon**: Shows red timer badge (≤3 days left)

### Refresh Options
- **Auto**: Every 30 minutes (when app is active)
- **Manual**: Pull down on deals section
- **Retry**: Tap retry button on error/offline states

## 🚀 Next Steps

### Recommended Enhancements
1. **Settings Screen**: Add UI for users to input/update API key
2. **Deal Details**: Full-screen deal details page
3. **Push Notifications**: Notify users of new deals
4. **Analytics**: Track which deals users view/tap
5. **Favorites**: Let users save favorite deals
6. **Share**: Share deals via social media

### Backend Recommendations
1. Add pagination for large deal lists
2. Add sorting (newest, discount%, expiring soon)
3. Add filtering by category
4. Add user-specific deals
5. Add deal analytics/tracking

## 📄 Code Example: Settings Screen

Create a settings screen to let users configure API key:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/deals_provider.dart';

class ApiKeySettingsScreen extends StatefulWidget {
  @override
  _ApiKeySettingsScreenState createState() => _ApiKeySettingsScreenState();
}

class _ApiKeySettingsScreenState extends State<ApiKeySettingsScreen> {
  final _apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('API Settings')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'Deals API Key',
                hintText: 'Enter your Railway API key',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final apiKey = _apiKeyController.text.trim();
                if (apiKey.isNotEmpty) {
                  context.read<DealsProvider>().setApiKey(apiKey);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('API key saved!')),
                  );
                }
              },
              child: Text('Save API Key'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🎉 Summary

✅ **Featured Services Removed**: Old static section deleted
✅ **Deals Section Added**: Dynamic API-driven deals
✅ **Offline Support**: Works without internet using mock data
✅ **Beautiful UI**: Professional design with animations
✅ **Error Handling**: User-friendly error messages
✅ **Smart Caching**: Reduces API calls, improves performance
✅ **Ready to Deploy**: Just add your API key!

---

**Need Help?** Check the debug logs in your terminal when running the app. The `deals_service.dart` file has extensive logging for troubleshooting.
