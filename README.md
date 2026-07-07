# iOS Keyboard Stuck After Quick App Switch

Minimal Flutter sample for an iOS `TextField` / keyboard state mismatch.

When a `TextField` is focused and the user quickly switches to another app with the iOS home indicator, the `TextField` can lose Flutter focus while the iOS keyboard remains visible.

This project intentionally does not include a workaround. It only logs Flutter lifecycle, focus, and inset state.

## Environment Used While Creating This Sample

```text
Flutter 3.35.1 stable
Dart 3.9.0
```

Run `flutter --version` locally and include the exact output when filing an issue.

## Run

```bash
flutter pub get
flutter devices
flutter run -d <ios-device-id>
```

Use an iOS simulator or a physical iOS device.

## Steps

1. Launch the app on iOS.
2. Tap any `TextField`.
3. Keep the iOS keyboard visible.
4. Quickly switch to another app using the iOS home indicator.
5. Return to this Flutter app.
6. Check the on-screen status panel and logs.

## Expected Result

One of these should happen:

- The keyboard is dismissed when the `TextField` loses focus.
- The `TextField` regains focus when the app returns.

The app should not end up with no Flutter focus while the iOS keyboard remains visible.

## Actual Result To Look For

The suspicious state is:

```text
primaryFocus=null
actual iOS keyboard still visible
```

The app also logs:

- `AppLifecycleState`
- `FocusManager.instance.primaryFocus`
- `FlutterView.viewInsets.bottom`
- `MediaQuery.viewInsets.bottom`

If the keyboard is visible while `primaryFocus=null`, record whether `viewInsets.bottom` is still non-zero.

## Notes For Filing A Flutter Issue

Useful details to attach:

- iOS version
- Flutter version
- physical device or simulator
- screen recording
- logs shown by this app
- whether focusing another `TextField` reconnects the keyboard
- whether pressing `Call primaryFocus?.unfocus()` changes anything after the bad state appears

Potential issue title:

```text
[iOS] Keyboard remains visible after quick app switch while TextField loses focus
```
