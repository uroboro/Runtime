#import "Runtime.h"

@interface RTIvar : NSObject
@property (nonatomic) Ivar internalIvar;
@property (nonatomic, assign) id owner;
+ (instancetype)ivarWithIvar:(Ivar)ivar andOwner:(id)owner;
- (instancetype)initWithIvar:(Ivar)ivar andOwner:(id)owner;

- (NSString *)name;
- (NSString *)type;
- (NSString *)typeWithName:(NSString *)name;
@end
