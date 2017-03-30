#import "Runtime.h"

@interface RTObject : NSObject
@property (nonatomic, assign) NSObject * internalObject;
+ (instancetype)objectWithObject:(NSObject *)object;
- (instancetype)initWithObject:(NSObject *)object;
@end
