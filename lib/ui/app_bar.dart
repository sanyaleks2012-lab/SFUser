import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sfuser/app.dart';
import 'package:sfuser/logic/records_manager.dart';
import 'package:sfuser/pages/debug.dart';
import 'package:sfuser/pages/settings.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  State<MainAppBar> createState() => _MainAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MainAppBarState extends State<MainAppBar> {
  Timer? _timer;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => _refreshStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Green when the active save matches the last saved state, yellow when
  /// there are changes that have not been saved yet.
  void _refreshStatus() {
    final record = RecordsManager.activeRecord;
    final unsaved =
        initialized.value && record != null && record.hasUnsavedChanges;
    if (unsaved != _hasUnsavedChanges && mounted) {
      setState(() => _hasUnsavedChanges = unsaved);
    }
  }

  @override
  Widget build(BuildContext _) {
    return Watch((context) => AppBar(
          toolbarHeight: 200,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.bug_report),
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const DebugPage())),
                          )),
                      if (package.value?.version != null)
                        Text(
                          "v${package.value?.version}",
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  )),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("SFUser"),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: _hasUnsavedChanges
                          ? "Unsaved changes"
                          : "All changes saved",
                      child: Icon(
                        Icons.circle,
                        size: 12,
                        color: _hasUnsavedChanges
                            ? Colors.amber
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SettingsPage())),
                  icon: const Icon(Icons.settings),
                ),
              ),
            ],
          ),
        ));
  }
}
