# Logo Setup Guide

## Adding Your Custom Logo

The app is configured to display a custom logo on the login and register screens. Follow these steps to add your logo:

### Step 1: Prepare Your Logo
- **Format**: PNG with transparent background (recommended)
- **Size**: 512x512 pixels or larger (square aspect ratio)
- **File name**: `logo.png`

### Step 2: Add Logo to Assets
1. Navigate to: `assets/images/`
2. Place your `logo.png` file in this folder

### Step 3: Verify Asset Declaration (Already Done)
The `pubspec.yaml` file already includes:
```yaml
flutter:
  assets:
    - assets/images/
```

### Step 4: Test the Logo
1. Save the logo file
2. Run the app: `flutter run`
3. Navigate to the login or register screen
4. Your logo should appear in a circular container at the top

## Default Fallback
If no `logo.png` file is found, the app will display:
- A gradient circular background (purple to pink)
- "LHS" text in white (Poppins font, bold, 32px)

This ensures the app looks professional even without a custom logo.

## Troubleshooting
- **Logo not appearing**: 
  - Ensure the file is named exactly `logo.png` (case-sensitive on some systems)
  - Verify it's in `assets/images/` folder
  - Run `flutter clean` and `flutter pub get`
  - Restart the app

- **Logo looks blurry**:
  - Use a higher resolution image (at least 512x512)
  - Ensure it's a PNG, not JPG

- **Logo has wrong colors**:
  - The logo is displayed as-is within a circular gradient container
  - Use a logo with transparent background for best results
