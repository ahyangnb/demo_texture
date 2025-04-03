#import <Flutter/Flutter.h>

@interface FlutterOpenglTexturePlugin : NSObject<FlutterPlugin>
// Registry used to register texture objects
@property (nonatomic, strong, readonly) id<FlutterTextureRegistry> textureRegistry;
@end
