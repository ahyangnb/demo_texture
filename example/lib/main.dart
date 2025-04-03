import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_opengl_texture/flutter_opengl_texture.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterOpenglTexturePlugin = FlutterOpenglTexture();
  int? _textureId;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _initTexture();
  }

  @override
  void dispose() {
    _disposeTexture();
    _updateTimer?.cancel();
    super.dispose();
  }

  // 初始化纹理 - Initialize texture
  Future<void> _initTexture() async {
    try {
      // 创建300x300的纹理 - Create 300x300 texture
      final result = await _flutterOpenglTexturePlugin.createTexture(300, 300);
      setState(() {
        _textureId = result['textureId'] as int;
      });

      // 设置定时器每秒更新纹理 - Set timer to update texture every second
      _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateTexture();
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to create texture: ${e.message}');
    }
  }

  // 更新纹理内容 - Update texture content
  Future<void> _updateTexture() async {
    if (_textureId != null) {
      try {
        await _flutterOpenglTexturePlugin.updateTexture(_textureId!);
      } catch (e) {
        debugPrint('Failed to update texture: $e');
      }
    }
  }

  // 释放纹理 - Dispose texture
  Future<void> _disposeTexture() async {
    if (_textureId != null) {
      try {
        await _flutterOpenglTexturePlugin.disposeTexture(_textureId!);
        setState(() {
          _textureId = null;
        });
      } catch (e) {
        debugPrint('Failed to dispose texture: $e');
      }
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterOpenglTexturePlugin.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OpenGL Texture Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion'),
              const SizedBox(height: 20),
              if (_textureId != null)
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Texture(textureId: _textureId!),
                )
              else
                const CircularProgressIndicator(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTexture,
                child: const Text('Update Texture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
