import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_opengl_texture_platform_interface.dart';

/// An implementation of [FlutterOpenglTexturePlatform] that uses method channels.
class MethodChannelFlutterOpenglTexture extends FlutterOpenglTexturePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_opengl_texture');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Map<String, dynamic>> createTexture(int width, int height,
      [Map<String, dynamic>? options]) async {
    final Map<String, dynamic> args = {
      'width': width,
      'height': height,
    };

    if (options != null) {
      args.addAll(options);
    }

    final Map<Object?, Object?>? result = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('createTexture', args);

    if (result == null) {
      throw PlatformException(
        code: 'texture_error',
        message: 'Failed to create texture',
      );
    }

    return result.cast<String, dynamic>();
  }

  @override
  Future<bool> disposeTexture(int textureId) async {
    final bool? result = await methodChannel
        .invokeMethod<bool>('disposeTexture', {'textureId': textureId});
    return result ?? false;
  }

  @override
  Future<bool> updateTexture(int textureId,
      [Map<String, dynamic>? params]) async {
    final Map<String, dynamic> args = {
      'textureId': textureId,
    };

    if (params != null) {
      args.addAll(params);
    }

    final bool? result =
        await methodChannel.invokeMethod<bool>('updateTexture', args);
    return result ?? false;
  }
}
