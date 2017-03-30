#import "Runtime.h"

@class RTIvar;

@interface RTClass : NSObject
@property (nonatomic) Class internalClass;
+ (instancetype)classWithClass:(Class)cls;
- (instancetype)initWithClass:(Class)cls;
- (RTIvar *)getInstanceVariableWithName:(NSString *)name;
@end
