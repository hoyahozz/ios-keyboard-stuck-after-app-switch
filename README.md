# iOS Keyboard Stuck After Quick App Switch

This repository contains a minimal Flutter app for checking an iOS keyboard state mismatch after quickly switching apps with the home indicator.

The app uses only Flutter `TextField` widgets and logs:

- `AppLifecycleState`
- `FocusManager.instance.primaryFocus`
- each sample `TextField` focus state
- `FlutterView.viewInsets.bottom`
- `MediaQuery.viewInsets.bottom`

No workaround is applied.

The important state to compare is whether Flutter reports that no sample `TextField` has focus while iOS still reports a non-zero keyboard inset.

## Screen Recording


<img width="362" height="789" alt="keyboard-stuck-result" src="https://github.com/user-attachments/assets/353823ad-fc12-4805-8a53-cf8d7154d93e" />


[keyboard-stuck-result.mov](media/keyboard-stuck-result.mov)

## Verified Environments

Initial recording:

```text
Flutter 3.35.1 stable
Dart 3.9.0
```

Latest verified reproduction:

```text
Flutter 3.44.5 stable
Dart 3.12.2
Xcode 26.2
iPhone 17, iOS 26.5.1
```

## Run

```bash
flutter pub get
flutter run -d <ios-device-id>
```

Use an iOS simulator or a physical iOS device.

## Steps

1. Launch the app on iOS.
2. Tap any `TextField`.
3. Keep the iOS keyboard visible.
4. Quickly switch to another app using the iOS home indicator.
5. Return to this Flutter app.
6. Check the status panel and logs.

## Expected

After returning to the app, Flutter should keep text input state consistent.

Either:

- the keyboard is dismissed when the `TextField` no longer has focus, or
- the focused `TextField` remains focused while the keyboard is visible.

## Actual

The app can return with no sample `TextField` focused while the iOS keyboard and keyboard inset are visible again.

Observed log shape on Flutter 3.44.5:

```text
lifecycle=AppLifecycleState.resumed
focus after lifecycle change: primaryFocus=_ModalScopeState<dynamic> Focus Scope; textFieldFocus=first=false, second=false, multiline=false
metrics after lifecycle change: viewInsets.bottom=physical=0.0, logical=0.0
metrics changed: viewInsets.bottom=physical=117.7, logical=39.2
metrics changed: viewInsets.bottom=physical=920.6, logical=306.9
metrics changed: viewInsets.bottom=physical=924.0, logical=308.0
```

This suggests that Flutter focus is no longer on a `TextField`, but the iOS keyboard / text input inset is still active.

## Notes

The sample includes a `Call primaryFocus?.unfocus()` button to check whether unfocusing the current primary focus changes the stuck keyboard state after it appears.

## Flutter Doctor

<details>
<summary>flutter doctor -v</summary>

```console
[✓] Flutter (Channel stable, 3.44.5, on macOS 26.5.1 25F80 darwin-arm64, locale ko-KR)
    • Flutter version 3.44.5 on channel stable at <flutter-sdk-path>
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision f94f4fc76b, 2026-07-06 11:19:24 -0700
    • Engine revision 83675ed276
    • Dart version 3.12.2
    • DevTools version 2.57.0
    • Feature flags: enable-web, enable-linux-desktop, enable-macos-desktop, enable-windows-desktop, enable-android, enable-ios, cli-animations, enable-native-assets, enable-swift-package-manager, omit-legacy-version-file, enable-lldb-debugging, enable-uiscene-migration

[✓] Android toolchain - develop for Android devices (Android SDK version 35.0.0)
    • Android SDK at <redacted>
    • Emulator version 36.1.9.0 (build_id 13823996) (CL:N/A)
    • Platform android-36, build-tools 35.0.0
    • Java binary at: /Applications/Android Studio Narwhal 3 Feature Drop 2025.1.3.app/Contents/jbr/Contents/Home/bin/java
    • Java version OpenJDK Runtime Environment (build 21.0.7+-13880790-b1038.58)
    • All Android licenses accepted.

[✓] Xcode - develop for iOS and macOS (Xcode 26.2)
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • Build 17C52
    • CocoaPods version 1.16.2

[✓] Chrome - develop for the web

[✓] Connected device
    • iPhone 17 (mobile)     • <redacted>      • ios            • iOS 26.5.1 23F81
    • iPhone 15 Pro          • <simulator-id>  • ios            • iOS 17.5 simulator
    • macOS                  • macos           • darwin-arm64   • macOS 26.5.1 25F80 darwin-arm64
    • Chrome                 • chrome          • web-javascript

[✓] Network resources
    • All expected network resources are available.

• No issues found!
```

</details>
