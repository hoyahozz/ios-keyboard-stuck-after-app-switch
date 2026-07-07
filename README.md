# iOS Keyboard Stuck After Quick App Switch

This is a minimal Flutter sample for an iOS keyboard state mismatch after quickly switching apps with the home indicator.

The sample uses only Flutter `TextField` widgets and logs:

- `AppLifecycleState`
- `FocusManager.instance.primaryFocus`
- each sample `TextField` focus state
- `FlutterView.viewInsets.bottom`
- `MediaQuery.viewInsets.bottom`

No workaround is applied.

## Screen Recording


<img width="362" height="789" alt="keyboard-stuck-result" src="https://github.com/user-attachments/assets/353823ad-fc12-4805-8a53-cf8d7154d93e" />


[keyboard-stuck-result.mov](media/keyboard-stuck-result.mov)

## Environment

The sample was created with:

```text
Flutter 3.35.1 stable
Dart 3.9.0
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

Observed log shape:

```text
lifecycle=AppLifecycleState.resumed
focus after lifecycle change: primaryFocus=_ModalScopeState<dynamic> Focus Scope; textFieldFocus=first=false, second=false, multiline=false
metrics after lifecycle change: viewInsets.bottom=physical=911.3, logical=303.8
```

This suggests that Flutter focus is no longer on a `TextField`, but the iOS keyboard / text input inset is still active.

## Notes

The sample includes a `Call primaryFocus?.unfocus()` button to check whether unfocusing the current primary focus changes the stuck keyboard state after it appears.
