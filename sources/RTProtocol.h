#import "Runtime.h"

@interface RTProtocol : NSObject
@property (nonatomic, assign) Protocol * internalProtocol;
+ (instancetype)protocolWithProtocol:(Protocol *)protocol;
- (instancetype)initWithProtocol:(Protocol *)protocol;
@end
