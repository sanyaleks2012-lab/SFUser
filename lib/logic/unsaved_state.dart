import 'package:flutter/widgets.dart';
import 'package:signals/signals.dart';

/// True when the active save has changes that were not saved yet.
/// Set by editing actions and cleared when the active save is written.
/// Cheap by design: nothing is serialized to find out whether changes exist.
final Signal<bool> hasUnsavedChanges = signal(false);

void markUnsaved() => hasUnsavedChanges.value = true;

void markSaved() => hasUnsavedChanges.value = false;

extension EditState<T extends StatefulWidget> on State<T> {
  /// Same as setState, but also marks the active save as changed.
  void editState(VoidCallback change) {
    markUnsaved();
    // ignore: invalid_use_of_protected_member
    setState(change);
  }
}
