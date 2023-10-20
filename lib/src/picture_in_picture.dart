import 'package:flutter/material.dart';

import 'picture_in_picture_platform_interface.dart';

class PictureInPicture {
  static Future<String> getPlatformVersion() {
    return PictureInPicturePlatform.instance.getPlatformVersion();
  }

  static Future<int> getPlatformSdk() {
    return PictureInPicturePlatform.instance.getPlatformSdk();
  }

  static Future<bool> isPiPSupported() {
    return PictureInPicturePlatform.instance.isPiPSupported();
  }

  static Future<bool> enterPip({int? width, int? height, Rect? rectHint}) {
    final mmmnotgood = _checkRatio(width: width, height: height);
    return PictureInPicturePlatform.instance.enterPip(
      height: mmmnotgood.$1,
      width: mmmnotgood.$2,
      rectHint: rectHint,
    );
  }

  static Future<bool> setAspectRatio({int? width, int? height}) {
    final mmmnotgood = _checkRatio(width: width, height: height);
    return PictureInPicturePlatform.instance.setAspectRatio(
      height: mmmnotgood.$1,
      width: mmmnotgood.$2,
    );
  }

  /// returns (height, width).
  static (int?, int?) _checkRatio({int? width, int? height}) {
    final ratio = width == null || height == null ? null : width / height;
    final mmmnotgood = ratio != null && (ratio < 0.418410 || ratio > 2.390000);
    return mmmnotgood ? (null, null) : (height, width);
  }

  static set onPipChanged(Function(bool isInPip) onPipChangedFunction) {
    PictureInPicturePlatform.instance.onPipChanged = onPipChangedFunction;
  }

  static set defaultPipStatusCheckTimerDuration(Duration duartion) {
    PictureInPicturePlatform.instance.defaultPipStatusCheckTimerDuration = duartion;
  }
}
