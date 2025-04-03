import 'flutter_opengl_texture_platform_interface.dart';

/// Main plugin class for FlutterOpenglTexture
class FlutterOpenglTexture {
  /// Gets the platform version.
  Future<String?> getPlatformVersion() {
    return FlutterOpenglTexturePlatform.instance.getPlatformVersion();
  }

  /// Creates a texture from native iOS content.
  ///
  /// Returns a map with the following keys:
  /// - 'textureId': The ID of the created texture.
  /// - 'width': The width of the texture.
  /// - 'height': The height of the texture.
  ///
  /// The textureId can be used with Flutter's Texture widget:
  /// ```dart
  /// Texture(textureId: textureId)
  /// ```
  ///
  /// [width] and [height] specify the desired size of the texture.
  /// [options] can include additional configuration parameters.
  Future<Map<String, dynamic>> createTexture(int width, int height,
      {Map<String, dynamic>? options}) {
    return FlutterOpenglTexturePlatform.instance
        .createTexture(width, height, options);
  }

  /// Disposes a previously created texture.
  ///
  /// [textureId] is the ID of the texture to dispose.
  /// Returns true if the texture was successfully disposed.
  Future<bool> disposeTexture(int textureId) {
    return FlutterOpenglTexturePlatform.instance.disposeTexture(textureId);
  }

  /// Updates the content of a texture.
  ///
  /// This triggers a redraw of the native texture content.
  /// [textureId] is the ID of the texture to update.
  /// [params] can include parameters that control the drawing.
  ///
  /// Returns true if the texture was successfully updated.
  Future<bool> updateTexture(int textureId, {Map<String, dynamic>? params}) {
    return FlutterOpenglTexturePlatform.instance
        .updateTexture(textureId, params);
  }
}
