#import "FlutterOpenglTexturePlugin.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

// iOS texture handler class
@interface IOSTextureHandler : NSObject <FlutterTexture>

// OpenGL context and related resources
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint framebuffer;
@property (nonatomic, assign) GLuint renderbuffer;
@property (nonatomic, assign) GLuint texture;

// Size properties
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;

// Last copied pixels
@property (nonatomic, strong) NSObject<FlutterTexture> *latestTextureBuffer;

// Initialization method
- (instancetype)initWithWidth:(int)width height:(int)height;

// Setup OpenGL resources
- (BOOL)setupGL;

// Clean up resources
- (void)cleanupGL;

// The method to update content
- (void)updateContent;

@end

@implementation IOSTextureHandler

- (instancetype)initWithWidth:(int)width height:(int)height {
    self = [super init];
    if (self) {
        _width = width;
        _height = height;
        [self setupGL];
    }
    return self;
}

- (void)dealloc {
    [self cleanupGL];
}

- (BOOL)setupGL {
    // 创建OpenGL上下文 - Create OpenGL context
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"Failed to create EAGLContext");
        return NO;
    }
    
    [EAGLContext setCurrentContext:self.context];
    
    // 创建帧缓冲区和渲染缓冲区 - Create framebuffer and renderbuffer
    glGenFramebuffers(1, &_framebuffer);
    glGenRenderbuffers(1, &_renderbuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, _width, _height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
    
    // 检查帧缓冲区状态 - Check framebuffer status
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object: %d", status);
        return NO;
    }
    
    // 创建初始纹理内容 - Create initial texture content
    [self updateContent];
    
    return YES;
}

- (void)cleanupGL {
    [EAGLContext setCurrentContext:self.context];
    
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
    
    self.context = nil;
}

- (void)updateContent {
    // 确保我们在正确的OpenGL上下文中 - Make sure we're in the correct OpenGL context
    [EAGLContext setCurrentContext:self.context];
    
    // 绑定帧缓冲区 - Bind framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    // 设置视口 - Set viewport
    glViewport(0, 0, _width, _height);
    
    // 清除颜色缓冲区并设置背景颜色 - Clear color buffer and set background color
    glClearColor(0.5f, 0.5f, 0.8f, 1.0f);  // 示例颜色 - Example color
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 在这里可以添加自定义绘制代码 - Add custom drawing code here
    
    // 示例：绘制一个简单的三角形 - Example: Draw a simple triangle
    const GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
       -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
    };
    
    const GLfloat colors[] = {
        1.0f, 0.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f,
    };
    
    // 简单的顶点着色器 - Simple vertex shader
    const char *vertexShaderSource =
        "attribute vec4 position;\n"
        "attribute vec4 color;\n"
        "varying vec4 fragColor;\n"
        "void main() {\n"
        "  fragColor = color;\n"
        "  gl_Position = position;\n"
        "}\n";
    
    // 简单的片元着色器 - Simple fragment shader
    const char *fragmentShaderSource =
        "varying highp vec4 fragColor;\n"
        "void main() {\n"
        "  gl_FragColor = fragColor;\n"
        "}\n";
    
    // 编译着色器 - Compile shaders
    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
    glCompileShader(vertexShader);
    
    GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
    glCompileShader(fragmentShader);
    
    // 创建程序并附加着色器 - Create program and attach shaders
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    
    // 使用程序 - Use program
    glUseProgram(program);
    
    // 获取属性位置 - Get attribute locations
    GLint positionAttrib = glGetAttribLocation(program, "position");
    GLint colorAttrib = glGetAttribLocation(program, "color");
    
    // 启用属性数组 - Enable attribute arrays
    glEnableVertexAttribArray(positionAttrib);
    glEnableVertexAttribArray(colorAttrib);
    
    // 设置顶点数据 - Set vertex data
    glVertexAttribPointer(positionAttrib, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glVertexAttribPointer(colorAttrib, 4, GL_FLOAT, GL_FALSE, 0, colors);
    
    // 绘制三角形 - Draw triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    // 禁用属性数组 - Disable attribute arrays
    glDisableVertexAttribArray(positionAttrib);
    glDisableVertexAttribArray(colorAttrib);
    
    // 删除着色器和程序 - Delete shaders and program
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    glDeleteProgram(program);
    
    // 绑定默认帧缓冲区 - Bind default framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

#pragma mark - FlutterTexture protocol

- (CVPixelBufferRef)copyPixelBuffer {
    // 确保我们在正确的OpenGL上下文中 - Make sure we're in the correct OpenGL context
    [EAGLContext setCurrentContext:self.context];
    
    // 绑定帧缓冲区 - Bind framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    // 创建CVPixelBuffer - Create CVPixelBuffer
    NSDictionary *options = @{
        (NSString*)kCVPixelBufferIOSurfacePropertiesKey: @{},
    };
    
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, _width, _height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &pixelBuffer);
    
    if (status != kCVReturnSuccess) {
        NSLog(@"Failed to create pixel buffer: %d", status);
        return NULL;
    }
    
    // 锁定像素缓冲区以便写入 - Lock pixel buffer for writing
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    // 获取像素缓冲区的基地址 - Get base address of pixel buffer
    void *pixelData = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // 从帧缓冲区读取像素数据 - Read pixel data from framebuffer
    glReadPixels(0, 0, _width, _height, GL_BGRA, GL_UNSIGNED_BYTE, pixelData);
    
    // 解锁像素缓冲区 - Unlock pixel buffer
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    // 绑定默认帧缓冲区 - Bind default framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    return pixelBuffer;
}

@end

@interface FlutterOpenglTexturePlugin ()
@property (nonatomic, strong) id<FlutterTextureRegistry> textureRegistry;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, IOSTextureHandler *> *textureHandlers;
@end

@implementation FlutterOpenglTexturePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_opengl_texture"
            binaryMessenger:[registrar messenger]];
  FlutterOpenglTexturePlugin* instance = [[FlutterOpenglTexturePlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    self = [super init];
    if (self) {
        _textureRegistry = [registrar textures];
        _textureHandlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"createTexture" isEqualToString:call.method]) {
    NSDictionary *args = call.arguments;
    NSNumber *width = args[@"width"];
    NSNumber *height = args[@"height"];
    
    // 创建纹理处理程序 - Create texture handler
    IOSTextureHandler *textureHandler = [[IOSTextureHandler alloc] initWithWidth:width.intValue height:height.intValue];
    
    // 注册纹理 - Register texture
    int64_t textureId = [self.textureRegistry registerTexture:textureHandler];
    
    // 存储纹理处理程序以备后用 - Store texture handler for later use
    self.textureHandlers[@(textureId)] = textureHandler;
    
    // 返回结果 - Return result
    result(@{
        @"textureId": @(textureId),
        @"width": width,
        @"height": height,
    });
  } else if ([@"disposeTexture" isEqualToString:call.method]) {
    NSDictionary *args = call.arguments;
    NSNumber *textureId = args[@"textureId"];
    
    // 获取纹理处理程序 - Get texture handler
    IOSTextureHandler *textureHandler = self.textureHandlers[textureId];
    
    if (textureHandler != nil) {
        // 注销纹理 - Unregister texture
        [self.textureRegistry unregisterTexture:textureId.longLongValue];
        
        // 从字典中移除 - Remove from dictionary
        [self.textureHandlers removeObjectForKey:textureId];
        
        result(@YES);
    } else {
        result(@NO);
    }
  } else if ([@"updateTexture" isEqualToString:call.method]) {
    NSDictionary *args = call.arguments;
    NSNumber *textureId = args[@"textureId"];
    
    // 获取纹理处理程序 - Get texture handler
    IOSTextureHandler *textureHandler = self.textureHandlers[textureId];
    
    if (textureHandler != nil) {
        // 更新纹理内容 - Update texture content
        [textureHandler updateContent];
        
        // 通知Flutter纹理已经更新 - Notify Flutter that texture has been updated
        [self.textureRegistry textureFrameAvailable:textureId.longLongValue];
        
        result(@YES);
    } else {
        result(@NO);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
