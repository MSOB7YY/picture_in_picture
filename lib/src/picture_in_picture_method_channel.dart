import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'picture_in_picture_platform_interface.dart';

/// An implementation of [PictureInPicturePlatform] that uses method channels.
class MethodChannelPictureInPicture extends PictureInPicturePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('picture_in_picture');

  MethodChannelPictureInPicture() {
    methodChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'isInPip') {
        final isInsidePip = call.arguments['isInsidePip'] as bool?;
        if (_onPipChanged != null) await _onPipChanged!(isInsidePip ?? false);
      }
    });
  }

  FutureOr<void> Function(bool isInPip)? _onPipChanged;

  Duration _pipStatusCheckTimerDuration = const Duration(milliseconds: 100);

  @override
  set defaultPipStatusCheckTimerDuration(Duration duration) {
    methodChannel.invokeMethod(
      'startPipCheckTimer',
      {"durationMS": duration.inMilliseconds},
    );
    _pipStatusCheckTimerDuration = duration;
  }

  @override
  set onPipChanged(Function(bool isInPip) onPipChangedFunction) {
    methodChannel.invokeMethod(
      'startPipCheckTimer',
      {"durationMS": _pipStatusCheckTimerDuration.inMilliseconds},
    );
    _onPipChanged = onPipChangedFunction;
  }

  @override
  Future<String> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String?>('getPlatformVersion');
    return version ?? '';
  }

  @override
  Future<int> getPlatformSdk() async {
    final version = await methodChannel.invokeMethod<int?>('getPlatformSdk');
    return version ?? 0;
  }

  @override
  Future<bool> isPiPSupported() async {
    final res = await methodChannel.invokeMethod<bool?>('isPiPSupported');
    return res ?? false;
  }

  @override
  Future<bool> enterPip({int? width, int? height}) async {
    final didEnter = await methodChannel.invokeMethod<bool?>(
      'enterPip',
      {'width': width, 'height': height},
    );
    return didEnter ?? false;
  }
}
