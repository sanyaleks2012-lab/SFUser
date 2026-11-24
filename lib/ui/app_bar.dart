import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sfuser/app.dart';
import 'package:sfuser/logic/unsaved_state.dart';
import 'package:sfuser/pages/debug.dart';
import 'package:sfuser/pages/settings.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

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
                    Watch((_) {
                      final unsaved = hasUnsavedChanges.value;
                      return Tooltip(
                        message:
                            unsaved ? "Unsaved changes" : "All changes saved",
                        child: Icon(
                          Icons.circle,
                          size: 12,
                          color: unsaved ? Colors.amber : Colors.green,
                        ),
                      );
                    }),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
