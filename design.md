# Step Count App — Design Document

## 1. Introduction

This document outlines the architecture, data flow, build system, and other design elements for the Step Count App, a native Apple Watch application designed to display today's total step count through both a watchOS app and a WidgetKit complication. The updated architecture follows modern watchOS conventions and best practices.

## 2. Target Architecture

### 2.1 Application Structure

The project will contain a native watchOS application target and a separate WidgetKit extension target that provides the circular Apple Watch complication.


```text
StepCountApp/
├── Shared/                              # Shared source directory
│   └── HealthKitService.swift          # HealthKit data access service
├── StepCountApp/                        # Main watchOS application target
│   ├── StepCountApp.swift              # App entry point
│   ├── Views/
│   │   └── ContentView.swift           # Main app view
│   └── Assets.xcassets                 # App assets
├── StepCountWidgetExtension/           # WidgetKit extension target
│   ├── StepCountWidget.swift           # Declares the WidgetKit widget, identifies the supported .accessoryCircular family, and connects the timeline provider to the widget view.
│   ├── StepCountTimelineProvider.swift # WidgetKit timeline provider
│   ├── Views/
│   │   └── StepCountWidgetView.swift   # Widget UI view
│   └── Assets.xcassets                 # Extension assets
├── project.yml                         # XcodeGen project specification
└── README.md                           # Project documentation
```

### 2.2 Target Membership

- **StepCountApp:** watchOS application target with all UI and app logic.
- **StepCountWidgetExtension:** WidgetKit extension target for complications.
- **HealthKitService.swift:** Shared data access component in the top-level Shared directory, included exactly once in each target's sources configuration.

## 3. System Requirements

### 3.1 Platform Requirements

- Target watchOS 27.0 and above (as it's the minimum version that supports all required APIs).
- Use XcodeGen with `project.yml` as the source of truth for configuration.
- Treat the generated `.xcodeproj` as a build artifact derived from `project.yml`.

### 3.2 Capabilities and Entitlements

**Required capabilities:**
1. **HealthKit:** HealthKit permissions (without background modes unless necessary).
2. **WidgetKit:** Widget extension configuration.

**Privacy settings:**
- Entitlements are managed through XcodeGen's `info` configuration in `project.yml`, where properties like `NSHealthShareUsageDescription` are defined directly within each target's `info.properties` section.

### 3.3 Data Source Implementation

- **Primary data source:** `HealthKit` using `HKQuantityType.quantityType(forIdentifier: .stepCount)`.
- Handle cases where HealthKit authorization has not been granted.
- Display `--` as a placeholder when no step data is available or before authorization.

## 4. Architecture Principles

### 4.1 Code Organization

- **App Target:** Contains all UI and application entry points in the main watchOS app target.
- **Extension Target:** Houses the WidgetKit timeline provider and complication UI.
- **Shared Services:** Data access components are shared between targets through proper integration.
- **Avoid Legacy Components:** Use modern SwiftUI for both UI elements, with no legacy ClockKit complications.

### 4.2 Service Layer Design

- Implement a single `HealthKitService` that can be used by both the main app and extension.
- Provide proper error handling and authorization management.
- Efficiently query today's step count using HealthKit APIs.

## 5. Data Flow Architecture

```text
[HealthKit] ←→ [HealthKitService]
          ↘            ↘
     [StepCountApp] [StepCountTimelineProvider]
          ↘            ↘
     [ContentView]   [StepCountWidgetView]
            ↘           ↘
       [WidgetKit]   [TimelineProvider]
```

### 5.1 Core Components

- **HealthKitService:** Implements actual HealthKit data-fetching operations.
- **StepCountApp:** Main application that handles authorization and UI logic.
- **StepCountTimelineProvider:** Implements the WidgetKit timeline provider.
- **StepCountWidgetView:** Custom SwiftUI views for widget display.

### 5.2 Data Handling

- Fetch today's cumulative step count from HealthKit directly when requested by WidgetKit.
- Automatically handle authorization requests in the main app.
- Format numbers over 999 using abbreviated notation (e.g., `1.5k`).
- Follow Apple's guidelines for battery optimization and data access frequency.

## 6. Build System and Configuration

### 6.1 Project Generation Process

1. Check that XcodeGen is available by running:
   ```bash
   xcodegen --version
   ```

2. Run XcodeGen from the project root:
   ```bash
   xcodegen generate
   ```

3. Verify that the resulting `.xcodeproj` exists and that the expected targets and files are present.
4. Inspect generated targets and extension configuration.
5. Build both targets using `xcodebuild` where supported.
6. Report any issues that cannot be verified without a physical Apple Watch.

### 6.2 XcodeGen Configuration (`project.yml`)

```yaml
name: StepCountApp

options:
  bundleIdPrefix: com.yourcompany
  deploymentTarget:
    watchOS: "27.0"

targets:
  StepCountApp:
    type: application.watchapp2
    platform: watchOS
    sources:
      - path: StepCountApp
      - path: Shared/HealthKitService.swift
    info:
      properties:
        NSHealthShareUsageDescription: "This app needs access to your step count data to display it on the watch face."

  StepCountWidgetExtension:
    type: watchkit2-extension
    platform: watchOS
    sources:
      - path: StepCountWidgetExtension
      - path: Shared/HealthKitService.swift
    info:
      properties:
        NSHealthShareUsageDescription: "This app needs access to your step count data to display it on the watch face."
```

### 6.3 Bundle Identifiers and Target Configuration

Use explicit, stable bundle identifiers for both targets. Do not rely on XcodeGen to infer or automatically generate bundle identifiers.

For this personal project, use the following identifiers:

- **WatchOS application target (`StepCountApp`):** `com.personal.stepcount`
- **WidgetKit extension target (`StepCountWidgetExtension`):** `com.personal.stepcount.widget`

Configure these identifiers explicitly in `project.yml` using the `PRODUCT_BUNDLE_IDENTIFIER` build setting for each target. The identifiers must be unique, consistent across builds, and correctly associated with their respective targets.

Example:

```yaml
targets:
  StepCountApp:
    type: application.watchos
    platform: watchOS
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.bigmacsoftware.stepcount
    # Preserve the existing sources and other settings.

  StepCountWidgetExtension:
    type: app-extension.watchos
    platform: watchOS
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.bigmacsoftware.stepcount.widget
    # Preserve the existing sources and other settings.
```

The snippet illustrates the required settings; integrate them into the existing target definitions rather than replacing other configuration.

After running `xcodegen generate`, verify that each generated target has the intended bundle identifier. Confirm that the widget extension's identifier is distinct from the app's identifier and that the extension is correctly embedded in the containing watchOS application.

Do not change these identifiers between builds unless there is a deliberate project identity change. If signing or installation requires additional configuration, report the issue and address it separately rather than silently changing the identifiers.

## 7. Implementation Strategy

### 7.1 Key Requirements Compliance

- **Update Frequency:** WidgetKit controls actual scheduling and may delay refreshes. Do not promise a refresh every 15 minutes.
- **Number Formatting:** Use abbreviated notation for numbers greater than 999 (e.g., `1.5k`).
- **Authorization Handling:** Display `--` when HealthKit data is unavailable or before authorization.
- **Widget Style:** Use `accessoryCircular` with a running shoe icon and below the icon the step count display.

### 7.2 WidgetKit Implementation
- Implement a circular/radial Apple Watch complication using WidgetKit's .accessoryCircular widget family.
- The complication must display a running-shoe SF Symbol and below that the formatted today's total step count in the circular complication area.
- Support the `accessoryCircular` family only.
- Use an appropriate timeline refresh policy, recognizing that WidgetKit controls actual scheduling and may delay updates.
- Query HealthKit directly when WidgetKit requests a timeline (no App Group cache).
- Implement a timeline provider that generates appropriate date ranges for widget updates.
- Use a reasonable refresh policy and handle midnight rollover appropriately.
- Format counts above 999 using abbreviated notation (e.g., 1.5k).

## 8. HealthKit Requirements

### 8.1 Data Queries

- Query cumulative daily steps using HealthKit's step-count quantity type and a date predicate beginning at the current calendar day's start.
- Use the appropriate HealthKit query for aggregation.
- Request read authorization through the main app's user-facing authorization flow.
- Handle missing samples, query errors, and unavailable data without crashing.
- Display `--` when no usable count is available.
- Do not claim that HealthKit can reliably distinguish denied read permission from an empty result.
- Verify all target-specific HealthKit capabilities, entitlements, and usage-description requirements.

### 8.2 Configuration

- Configure the required HealthKit capability for each target that needs HealthKit access.
- Both the main app and extension targets include NSHealthShareUsageDescription in their respective info.properties sections of `project.yml` 
- Remove assumption of background modes unless genuine need is demonstrated through supported implementation.
- The main app initiates the authorization flow; the widget queries HealthKit directly when its timeline provider executes.

## 9. Testing Approach

### 9.1 Simulator Testing

- Build and verify compilation in the simulator environment.
- Validate that the project builds successfully using Apple's guidelines.
- Test UI components without HealthKit integration; HealthKit integration will be tested on a physical device.

### 9.2 Physical Device Testing

- Verify the actual HealthKit permissions flow on a physical Apple Watch.
- Confirm that the widget updates at appropriate intervals.
- Validate display formats and theming across different watch faces.
- Test midnight rollover behavior to ensure step count accuracy.
- Test that authorization flows correctly in the main app.
- Ensure widget can query step counts under configured permissions.
- Handle empty results, errors, and unavailable HealthKit data gracefully.

## 10. Compliance with Apple Guidelines

### 10.1 Battery Optimization

- Follow Apple's guidelines for HealthKit access patterns.
- Use minimal resources during data-fetching operations.
- Implement automatic update scheduling through the WidgetKit system.
- Maintain appropriate refresh rates to preserve battery life.

### 10.2 HealthKit Usage

- Properly request and handle HealthKit authorizations.
- Handle cases where users have not granted HealthKit permissions.
- Display appropriate placeholders during the authorization flow.

## 11. Future Considerations

The design document accounts for the following future enhancements:

- Manual refresh capability.
- Additional data formats, such as distance traveled.
- Different complication styles.
- Historical step-count display.

These features can be implemented as extensions to the existing architecture without requiring significant rework.

## 12. Summary of Key Design Decisions

1. **Single-target approach:** Main application with a separate extension for WidgetKit.
2. **Modern SwiftUI:** UI components built using modern SwiftUI patterns.
3. **XcodeGen integration:** Complete configuration managed through `project.yml`.
4. **Service-oriented architecture:** Clean separation of data access from UI logic.
5. **Direct HealthKit querying:** Widget queries HealthKit directly, not using App Group or saved value cache.
6. **Shared source organization:** HealthKitService in Shared directory with explicit inclusion in each target once only.
7. **Appropriate error handling:** Graceful degradation when HealthKit authorization is missing.
8. **WidgetKit compliance:** Proper implementation following Apple's widget guidelines.
9. **Minimal approach:** No background delivery or extra service layers beyond essentials.
10. **XCodeGen configuration:** All build-time settings, including Info.plist entries and entitlements are managed through `project.yml` using XcodeGen's `info.properties` configuration.

This design document provides a robust foundation for the Step Count App that meets all current requirements while providing flexibility for future enhancements.
