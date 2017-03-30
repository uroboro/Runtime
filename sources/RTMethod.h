#import "Runtime.h"

@interface RTMethod : NSObject
@property (nonatomic) Method internalMethod;
@property (nonatomic, assign) id owner;
+ (instancetype)methodWithMethod:(Method)method andOwner:(id)owner;
- (instancetype)initWithMethod:(Method)method andOwner:(id)owner;

- (NSString *)name;
@property (nonatomic, assign) BOOL isClassMethod;
@end
