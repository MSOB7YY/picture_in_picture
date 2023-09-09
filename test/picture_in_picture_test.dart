import 'package:flutter_test/flutter_test.dart';
import 'package:picture_in_picture/picture_in_picture.dart';
import 'package:picture_in_picture/src/picture_in_picture_method_channel.dart';
import 'package:picture_in_picture/src/picture_in_picture_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPictureInPicturePlatform
    with MockPlatformInterfaceMixin
    implements PictureInPicturePlatform {
  @override
  Future<String> getPlatformVersion() => Future.value('42');

  @override
  set defaultPipStatusCheckTimerDuration(Duration duration) {}

  @override
  Future<bool> enterPip({int? width, int? height}) {
    throw UnimplementedError();
  }

  @override
  Future<int> getPlatformSdk() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isPiPSupported() {
    throw UnimplementedError();
  }

  @override
  set onPipChanged(Function(bool isInPip) onPipChangedFunction) {}
}

void main() {
  final PictureInPicturePlatform initialPlatform =
      PictureInPicturePlatform.instance;

  test('$MethodChannelPictureInPicture is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPictureInPicture>());
  });

  test('getPlatformVersion', () async {
    MockPictureInPicturePlatform fakePlatform = MockPictureInPicturePlatform();
    PictureInPicturePlatform.instance = fakePlatform;

    expect(await PictureInPicture.getPlatformVersion(), '42');
  });
}
