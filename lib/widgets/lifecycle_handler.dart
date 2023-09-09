import 'package:flutter/material.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function()? resumeCallBack;
  final Future<void> Function()? suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) await resumeCallBack!();
        break;
      case AppLifecycleState.inactive:
        if (suspendingCallBack != null) await suspendingCallBack!();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
    }
  }
}
