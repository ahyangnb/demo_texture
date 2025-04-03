import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_opengl_texture_method_channel.dart';

abstract class FlutterOpenglTexturePlatform extends PlatformInterface {
  /// Constructs a FlutterOpenglTexturePlatform.
  FlutterOpenglTexturePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterOpenglTexturePlatform _instance =
      MethodChannelFlutterOpenglTexture();

  /// The default instance of [FlutterOpenglTexturePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterOpenglTexture].
  static FlutterOpenglTexturePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterOpenglTexturePlatform] when
  /// they register themselves.
  static set instance(FlutterOpenglTexturePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Creates a texture from native iOS content.
  ///
  /// Returns a map with texture ID and size information.
  /// The texture ID can be used with [Texture] widget in Flutter.
  ///
  /// [width] and [height] specify the desired size of the texture.
  /// [options] can include additional parameters for texture creation.
  Future<Map<String, dynamic>> createTexture(int width, int height,
      [Map<String, dynamic>? options]) {
    throw UnimplementedError('createTexture() has not been implemented.');
  }

  /// Disposes a previously created texture.
  ///
  /// [textureId] is the ID of the texture to dispose.
  Future<bool> disposeTexture(int textureId) {
    throw UnimplementedError('disposeTexture() has not been implemented.');
  }

  /// Updates the content of a texture.
  ///
  /// This triggers a redraw of the native texture content.
  /// [textureId] is the ID of the texture to update.
  /// [params] can include parameters that control the drawing.
  Future<bool> updateTexture(int textureId, [Map<String, dynamic>? params]) {
    throw UnimplementedError('updateTexture() has not been implemented.');
  }
}
