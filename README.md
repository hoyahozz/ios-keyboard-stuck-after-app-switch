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

Latest verified intermittent reproduction:

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

The app can intermittently return with no sample `TextField` focused while the iOS keyboard and keyboard inset are visible again.

The following Flutter 3.44.5 logs were captured from the same physical iPhone run. The issue was reproduced with all three sample `TextField` widgets.

First `TextField`:

```console
flutter: 11:19:04.446 primary focus changed: primaryFocus=first_text_field; textFieldFocus=first=true, second=false, multiline=false
flutter: 11:19:07.275 lifecycle=AppLifecycleState.inactive
flutter: 11:19:07.275 focus after lifecycle change: primaryFocus=first_text_field; textFieldFocus=first=true, second=false, multiline=false
flutter: 11:19:07.974 primary focus changed: primaryFocus=_ModalScopeState<dynamic> Focus Scope; textFieldFocus=first=false, second=false, multiline=false
flutter: 11:19:08.623 lifecycle=AppLifecycleState.resumed
flutter: 11:19:08.624 focus after lifecycle change: primaryFocus=_ModalScopeState<dynamic> Focus Scope; textFieldFocus=first=false, second=false, multiline=false
flutter: 11:19:08.624 metrics after lifecycle change: viewInsets.bottom=physical=911.1, logical=303.7
flutter: 11:19:08.770 metrics changed: viewInsets.bottom=physical=924.0, logical=308.0
```

Second `TextField`:

```console
flutter: 11:19:15.704 primary focus changed: primaryFocus=second_text_field; textFieldFocus=first=false, second=true, multiline=false
flutter: 11:19:16.599 lifecycle=AppLifecycleState.inactive
flutter: 11:19:16.600 focus after lifecycle change: primaryFocus=second_text_field; textFieldFocus=first=false, second=true, multiline=false
flutter: 11:19:17.186 primary focus changed: primaryFocus=_ModalScopeState<dynamic> Focus Scope; textFieldFocus=first=false, second=false, multiline=false
flutter: 11:19:17.950 lifecycle=AppLifecycleState.resumed
flutter: 11:19:17.950 focus after lifecycle change: primaryFocus=_ModalScopeState<dynamic> Focus Scope; textFieldFocus=first=false, second=false, multiline=false
flutter: 11:19:17.950 metrics after lifecycle change: viewInsets.bottom=physical=920.7, logical=306.9
flutter: 11:19:18.047 metrics changed: viewInsets.bottom=physical=924.0, logical=308.0
```

Multiline `TextField`:

```console
flutter: 11:19:21.530 primary focus changed: primaryFocus=multiline_text_field; textFieldFocus=first=false, second=false, multiline=true
flutter: 11:19:22.156 lifecycle=AppLifecycleState.inactive
flutter: 11:19:22.156 focus after lifecycle change: primaryFocus=multiline_text_field; textFieldFocus=first=false, second=false, multiline=true
flutter: 11:19:22.913 primary focus changed: primaryFocus=_ModalScopeState<dynamic> Focus Scope; textFieldFocus=first=false, second=false, multiline=false
flutter: 11:19:23.662 lifecycle=AppLifecycleState.resumed
flutter: 11:19:23.662 focus after lifecycle change: primaryFocus=_ModalScopeState<dynamic> Focus Scope; textFieldFocus=first=false, second=false, multiline=false
flutter: 11:19:23.662 metrics after lifecycle change: viewInsets.bottom=physical=917.5, logical=305.8
flutter: 11:19:23.765 metrics changed: viewInsets.bottom=physical=924.0, logical=308.0
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
