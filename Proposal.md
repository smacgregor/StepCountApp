# Step Count App – Product Proposal

## 1. Overview

A native Apple Watch application designed to display today's total step count through both a watchOS app and a WidgetKit complication. The app will utilize HealthKit data to provide accurate step-tracking information.

## 2. Requirements

### 2.1 Core Functionality

#### watchOS App
- Display today's total step count.
- Show `--` as a placeholder when no data is available or before authorization.
- Show only the step count, without any additional UI elements.

#### WidgetKit Complication
- Use the `accessoryCircular` style.
- Include a small running shoe icon that inherits the watch theme color.
- Display the step count underneath the shoe icon.
- Format numbers over 999 using abbreviated notation, such as `1.5k`.

#### Data Management
- Utilize HealthKit to access step-count data.
- Handle cases where HealthKit authorization has not been granted.
- Show `--` when no step data is available or before authorization.

#### Update Frequency
- Update approximately every 15 minutes, following Apple's guidelines.
- Update automatically without manual user interaction.

### 2.2 Data Formatting

- Format numbers over 999 using abbreviated notation, such as `1.5k`.
- Apply this format consistently across both the watchOS app and the complication.

## 3. Technical Considerations

### 3.1 Data Source
- **Primary data source:** HealthKit.
- Appropriate permissions are required to access step-count information.

### 3.2 Authorization Handling
- Gracefully handle scenarios where HealthKit authorization has not yet been granted.
- Display the placeholder `--` in such cases.
- Consider implementing authorization prompts, although the primary requirement is to display `--` when data is unavailable.

### 3.3 Performance
- Follow Apple's guidelines for update frequency to optimize battery life.
- Ensure smooth performance across all supported watchOS versions.

## 4. Future Considerations

This initial version focuses on core functionality. Potential future enhancements include:

- Manual refresh capability.
- Support for additional data formats, such as distance traveled.
- Additional complications in different styles.
- Historical step-count display.

## 5. Acceptance Criteria

1. Step count displays correctly in both the watchOS app and the complication.
2. Number formatting works correctly, displaying abbreviated values such as `1.5k` when applicable.
3. The `--` placeholder appears when data is unavailable or before authorization.
4. Updates occur automatically approximately every 15 minutes, subject to watchOS scheduling constraints.
5. The app handles HealthKit authorization gracefully.

## 6. Summary of Key Requirements

Based on the agreed requirements, the following decisions define the initial product scope:

1. **Data source:** HealthKit.
2. **Step-count formatting:** Use abbreviated notation for numbers over 999, such as `1.5k`.
3. **Authorization handling:** Show `--` when step-count data is unavailable.
4. **Update frequency:** Target automatic updates approximately every 15 minutes, subject to Apple's watchOS guidelines.

This proposal outlines a clean, minimal app focused on displaying step-count information in a user-friendly way while following Apple's design principles and guidelines for watchOS apps.


