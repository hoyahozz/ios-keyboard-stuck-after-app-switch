import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  runApp(const KeyboardAppSwitchApp());
}

final class KeyboardAppSwitchApp extends StatelessWidget {
  const KeyboardAppSwitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Keyboard App Switch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const KeyboardAppSwitchPage(),
    );
  }
}

final class KeyboardAppSwitchPage extends StatefulWidget {
  const KeyboardAppSwitchPage({super.key});

  @override
  State<KeyboardAppSwitchPage> createState() => _KeyboardAppSwitchPageState();
}

final class _KeyboardAppSwitchPageState extends State<KeyboardAppSwitchPage>
    with WidgetsBindingObserver {
  final FocusNode _firstFocusNode = FocusNode(debugLabel: "first_text_field");
  final FocusNode _secondFocusNode = FocusNode(debugLabel: "second_text_field");
  final FocusNode _multilineFocusNode = FocusNode(
    debugLabel: "multiline_text_field",
  );
  final List<String> _logs = [];

  AppLifecycleState? _lifecycleState;
  String _lastFocusDescription = "null";
  String _lastInsetsDescription = "unknown";

  @override
  void initState() {
    super.initState();
    _lifecycleState = WidgetsBinding.instance.lifecycleState;
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_handlePrimaryFocusChanged);
    _record("initial lifecycle=$_lifecycleState");
    _recordFocus("initial focus");
    _recordMetrics("initial metrics");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    _record("lifecycle=$state");
    _recordFocus("focus after lifecycle change");
    _recordMetrics("metrics after lifecycle change");
  }

  @override
  void didChangeMetrics() {
    _recordMetrics("metrics changed");
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handlePrimaryFocusChanged);
    WidgetsBinding.instance.removeObserver(this);
    _firstFocusNode.dispose();
    _secondFocusNode.dispose();
    _multilineFocusNode.dispose();
    super.dispose();
  }

  void _handlePrimaryFocusChanged() {
    _recordFocus("primary focus changed");
  }

  void _recordFocus(String reason) {
    _lastFocusDescription = _describePrimaryFocus();
    _record("$reason: primaryFocus=$_lastFocusDescription");
  }

  void _recordMetrics(String reason) {
    final ui.FlutterView view =
        WidgetsBinding.instance.platformDispatcher.views.first;
    final double physicalBottomInset = view.viewInsets.bottom;
    final double logicalBottomInset =
        physicalBottomInset / view.devicePixelRatio;

    _lastInsetsDescription =
        "physical=${physicalBottomInset.toStringAsFixed(1)}, logical=${logicalBottomInset.toStringAsFixed(1)}";
    _record("$reason: viewInsets.bottom=$_lastInsetsDescription");
  }

  String _describePrimaryFocus() {
    final FocusNode? primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return "null";

    final String? debugLabel = primaryFocus.debugLabel;
    if (debugLabel != null && debugLabel.isNotEmpty) return debugLabel;

    return primaryFocus.toString();
  }

  void _unfocusPrimaryFocus() {
    final String previousFocus = _describePrimaryFocus();
    FocusManager.instance.primaryFocus?.unfocus();
    _record("manual unfocus requested; previous primaryFocus=$previousFocus");
  }

  void _clearLogs() {
    setState(_logs.clear);
  }

  void _record(String message) {
    final String entry = "${_timestamp()} $message";
    debugPrint(entry);

    if (!mounted) {
      _insertLog(entry);
      return;
    }

    setState(() {
      _insertLog(entry);
    });
  }

  void _insertLog(String entry) {
    _logs.insert(0, entry);
    if (_logs.length > 80) {
      _logs.removeLast();
    }
  }

  String _timestamp() {
    final DateTime now = DateTime.now();
    final String hour = now.hour.toString().padLeft(2, "0");
    final String minute = now.minute.toString().padLeft(2, "0");
    final String second = now.second.toString().padLeft(2, "0");
    final String millisecond = now.millisecond.toString().padLeft(3, "0");
    return "$hour:$minute:$second.$millisecond";
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryBottomInset = MediaQuery.viewInsetsOf(
      context,
    ).bottom;

    return Scaffold(
      appBar: AppBar(title: const Text("iOS Keyboard App Switch")),
      body: SafeArea(
        child: ListView(
          key: const ValueKey("keyboard_app_switch_scroll_view"),
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Steps",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "1. Focus any TextField.\n"
              "2. While the iOS keyboard is visible, quickly switch to another app using the home indicator.\n"
              "3. Return to this app.\n"
              "4. Check whether primaryFocus is null while the iOS keyboard is still visible.",
            ),
            const SizedBox(height: 16),
            _StatusPanel(
              lifecycleState: _lifecycleState,
              primaryFocus: _lastFocusDescription,
              viewInsets: _lastInsetsDescription,
              mediaQueryBottomInset: mediaQueryBottomInset,
            ),
            const SizedBox(height: 16),
            TextField(
              focusNode: _firstFocusNode,
              decoration: const InputDecoration(
                labelText: "First TextField",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              focusNode: _secondFocusNode,
              decoration: const InputDecoration(
                labelText: "Second TextField",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              focusNode: _multilineFocusNode,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Multiline TextField",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _unfocusPrimaryFocus,
                  child: const Text("Call primaryFocus?.unfocus()"),
                ),
                OutlinedButton(
                  onPressed: _clearLogs,
                  child: const Text("Clear logs"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Logs",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _LogList(logs: _logs),
          ],
        ),
      ),
    );
  }
}

final class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.lifecycleState,
    required this.primaryFocus,
    required this.viewInsets,
    required this.mediaQueryBottomInset,
  });

  final AppLifecycleState? lifecycleState;
  final String primaryFocus;
  final String viewInsets;
  final double mediaQueryBottomInset;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusRow(
              label: "Lifecycle",
              value: lifecycleState?.toString() ?? "unknown",
            ),
            _StatusRow(label: "Primary focus", value: primaryFocus),
            _StatusRow(label: "FlutterView inset", value: viewInsets),
            _StatusRow(
              label: "MediaQuery inset",
              value: mediaQueryBottomInset.toStringAsFixed(1),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

final class _LogList extends StatelessWidget {
  const _LogList({required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Text("No logs yet.");
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final String log in logs)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SelectableText(
                  log,
                  style: const TextStyle(fontFamily: "monospace", fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
