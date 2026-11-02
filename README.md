# StepCountApp

This is a watchOS application with a widget extension that accesses HealthKit step count data.

## Project Structure

- `StepCountApp/` - Main watchOS application target
- `StepCountWidgetExtension/` - Widget extension target  
- `Shared/` - Shared code between targets

## HealthKit Configuration

The project is configured to access HealthKit step count data with proper entitlements:

1. Both targets have appropriate HealthKit entitlements in their respective `.entitlements` files
2. Privacy descriptions are included in each target's Info.plist file:
   - `StepCountApp/Info.plist` 
   - `StepCountWidgetExtension/Info.plist`
3. The app uses `WKWatchKitApp: true` setting
4. The widget extension uses `WKApplication: true` setting

## Building

This project is configured for XcodeGen. To regenerate the Xcode project:

```bash
xcodegen generate
```

After generation, open `StepCountApp.xcodeproj` and build in Xcode.