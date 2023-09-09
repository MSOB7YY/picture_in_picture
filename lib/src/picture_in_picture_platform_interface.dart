import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'picture_in_picture_method_channel.dart';

abstract class PictureInPicturePlatform extends PlatformInterface {
  /// Constructs a PictureInPicturePlatform.
  PictureInPicturePlatform() : super(token: _token);

  static final Object _token = Object();

  static PictureInPicturePlatform _instance = MethodChannelPictureInPicture();

  /// The default instance of [PictureInPicturePlatform] to use.
  ///
  /// Defaults to [MethodChannelPictureInPicture].
  static PictureInPicturePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PictureInPicturePlatform] when
  /// they register themselves.
  static set instance(PictureInPicturePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int> getPlatformSdk() {
    throw UnimplementedError('getPlatformSdk() has not been implemented.');
  }

  Future<bool> isPiPSupported() {
    throw UnimplementedError('isPiPSupported() has not been implemented.');
  }

  Future<bool> enterPip({int? width, int? height}) {
    throw UnimplementedError('enterPip() has not been implemented.');
  }

  set onPipChanged(Function(bool isInPip) onPipChangedFunction) {
    throw UnimplementedError('onPipChanged setter is no available.');
  }

  set defaultPipStatusCheckTimerDuration(Duration duration) {
    throw UnimplementedError(
        'defaultPipStatusCheckTimerDuration setter is no available.');
  }
}
