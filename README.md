# Flutter AR Assignment — AR Object Placement App

## Project Overview

This Flutter-based Android application demonstrates real-world Augmented Reality (AR) using Google ARCore. The application is designed with a kid-friendly user experience and emphasizes stability, correctness, and accurate AR hit-testing. Users can detect horizontal surfaces, place a single 3D cube anchored in world coordinates, and interact with the cube via a tap that reveals an educational information card.

## Table of Contents

* [Features](#features)
* [Technical Decisions & Architecture](#technical-decisions--architecture)
* [Dependencies](#dependencies)
* [Prerequisites](#prerequisites)
* [Project Structure (recommended)](#project-structure-recommended)
* [Build & Installation Instructions](#build--installation-instructions)
* [Usage Guide](#usage-guide)
* [Reset & Replay Cycle](#reset--replay-cycle)
* [Troubleshooting](#troubleshooting)
* [Known Limitations](#known-limitations)
* [Testing Guidance](#testing-guidance)
* [Contributing](#contributing)
* [License](#license)
* [Acknowledgements](#acknowledgements)
* [Contact](#contact)

## Features

1. **AR Scene Setup**

    * Camera opens on app launch (AR view using `arcore_flutter_plugin`).
    * Automatic detection of horizontal planes (tables, floors).
    * On-screen instructions: guidance to move the phone slowly and to tap a detected surface to place the object.

2. **3D Object Placement**

    * Real-world anchoring through AR hit-testing; placed object is anchored at detected world coordinates.
    * Single-object placement per session to avoid scene clutter and anchor drift.
    * The object is a primitive cube (no floating UI overlay).

3. **Interactive Elements**

    * Tap-to-interact: tapping the placed cube opens an information card.
    * Information card explains the object, how AR positions it, and confirms the anchor persists as the camera moves.

4. **Kid-Friendly UX**

    * Minimalist UI with large readable text and simple controls.
    * Intuitive one-tap flow; no complex gestures.
    * Error prevention through clear labels and restricted actions.

5. **Session Management**

    * Dedicated Reset button to clear the scene and restart the AR session safely.

## Technical Decisions & Architecture

* **Primitive Choice:** A primitive cube is used instead of complex GLTF/OBJ models to ensure consistent rendering across low-end devices and to reduce anchor drift and runtime issues.
* **Stability Over Transformation:** Interaction is implemented as an informational overlay rather than runtime scaling/rotation. This avoids known runtime mutation issues in the chosen plugin and ensures crash-free behavior.
* **Performance:** `enableUpdateListener` is disabled to avoid per-frame pose recalculation overhead. This improves camera feed smoothness and battery life.
* **Safe Lifecycle Management:** The AR view controller is disposed and re-created safely on Reset to prevent memory leaks and crashes.
* **Plugin Constraints:** Implementation accounts for limitations in `arcore_flutter_plugin` (runtime mutations, lifecycle handling) and uses stable APIs (hitTest / anchors).

## Dependencies

* Flutter SDK (stable channel)
* `arcore_flutter_plugin` (or an equivalent ARCore Flutter plugin compatible with your Flutter SDK version)
* (Optional) `provider` / `bloc` — if using for state management (not required for minimal example)

> Example pubspec dependency snippet:

```yaml
dependencies:
  flutter:
    sdk: flutter
  arcore_flutter_plugin: ^0.0.16 # replace with the plugin version compatible with your setup
```

## Prerequisites

* Flutter SDK installed and configured.
* A physical Android device with:

    * Android 7.0+ (Nougat)
    * ARCore support
    * Google Play Services for AR installed and up to date
* USB debugging enabled (for development and testing)
* Camera permission granted to the app at runtime

## Build & Installation Instructions

### Clean and prepare

```bash
flutter clean
flutter pub get
```

### Run on a connected Android device (debug)

```bash
flutter run --release
# or for debug
flutter run
```

> Note: For AR testing prefer `--release` build for more reliable performance and accurate behavior on-device.

### Build release APK

```bash
flutter build apk --release
```

### AndroidManifest and permissions

Ensure `AndroidManifest.xml` includes the camera permission and required features:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera.ar" android:required="true" />
```

Also confirm that the app targets an Android SDK level compatible with the ARCore plugin.

## Usage Guide

1. Install the APK or run the app from your IDE on a supported device.
2. On launch, the camera view will appear and the app will begin plane detection.
3. Move the phone slowly to allow ARCore to detect horizontal surfaces; follow the on-screen prompt.
4. Tap on a detected surface to place the cube. Only one cube is placed per session.
5. Tap the cube to view the info card which explains the object and AR behavior.
6. Use the Reset button to clear anchors and restart detection.

## Reset & Replay Cycle

* The Reset action safely disposes of the AR controller, removes anchors, and re-initializes the AR session.
* This avoids full application restarts and prevents memory leaks or controller state corruption.
* Implementation notes:

    * Stop any listeners and then call controller.dispose().
    * Recreate the controller instance and re-attach necessary handlers.

## Troubleshooting

* **AR not starting / black screen**

    * Verify camera permission is granted.
    * Ensure Google Play Services for AR (ARCore) is installed and up to date.
    * Confirm the device is ARCore-compatible (check on the official ARCore supported devices list).
* **Hit tests failing / cannot place object**

    * Ensure there is adequate texture/feature in the scene (flat, textureless white surfaces may be hard to detect).
    * Move the device slowly and scan the environment to allow ARCore to collect feature points.
* **App crashes on specific devices**

    * Check plugin compatibility with the target Android API and Gradle version.
    * Run `flutter run --verbose` to collect logs and trace the crash source.
* **Object drifts**

    * Minor drift is expected on lower-end devices. Use stable anchors, limit placed object count, and avoid dynamic runtime transformations to minimize drift.

## Known Limitations

* Single primitive cube only; no runtime scaling or rotation controls to prevent plugin instability.
* No support for complex multi-object scenes (by design to prioritize stability).
* Visual sophistication (shadows, PBR materials) intentionally omitted to maximize cross-device reliability.

## Testing Guidance

* Test on physical devices only (ARCore functionality is not available on emulators).
* Prefer testing in environments with rich visual features and good lighting.
* Record `adb logcat` output when diagnosing plugin or lifecycle issues.

## Contributing

* Bug reports, improvements, and pull requests are welcome.
* Follow the repository standards:

    * Create a new branch per feature/fix.
    * Provide reproducible steps for bugs and a concise description of changes in pull requests.

## Acknowledgements

* ARCore team and documentation for AR development guidance.
* Authors and maintainers of `arcore_flutter_plugin` (or chosen AR plugin) for enabling AR on Flutter.
