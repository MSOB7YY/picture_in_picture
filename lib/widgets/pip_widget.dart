import 'package:flutter/material.dart';
import 'package:picture_in_picture/src/picture_in_picture.dart';
import 'package:picture_in_picture/widgets/lifecycle_handler.dart';

class PipWidget extends StatefulWidget {
  final Widget child;
  final Widget pipChild;
  final Future<void> Function()? onResume;
  final Future<void> Function()? onSuspending;
  final bool isEnteringHomeOnSuspending;

  const PipWidget({
    super.key,
    required this.child,
    required this.pipChild,
    this.onResume,
    this.onSuspending,
    required this.isEnteringHomeOnSuspending,
  });

  @override
  State<PipWidget> createState() => _PipWidgetState();
}

class _PipWidgetState extends State<PipWidget> with WidgetsBindingObserver {
  bool isInPip = false;

  late WidgetsBindingObserver observer;

  @override
  void initState() {
    if (!widget.isEnteringHomeOnSuspending) {
      PictureInPicture.onPipChanged = (ispip) {
        setState(() => isInPip = ispip);
      };
    }

    super.initState();
    observer = LifecycleEventHandler(
      resumeCallBack: () async {
        await widget.onResume?.call();
        if (widget.isEnteringHomeOnSuspending) {
          setState(() => isInPip = false);
        }
      },
      suspendingCallBack: () async {
        await widget.onSuspending?.call();
        if (widget.isEnteringHomeOnSuspending) {
          setState(() => isInPip = true);
        }
      },
    );
    WidgetsBinding.instance.addObserver(observer);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isInPip ? widget.pipChild : widget.child;
  }
}
