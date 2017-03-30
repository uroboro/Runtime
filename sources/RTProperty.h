#import "Runtime.h"

@interface RTProperty : NSObject
@property (nonatomic) Property internalProperty;
@property (nonatomic, assign) id owner;
+ (instancetype)propertyWithProperty:(Property)property andOwner:(id)owner;
- (instancetype)initWithProperty:(Property)property andOwner:(id)owner;

- (NSString *)backingIvar;
- (NSString *)getter;
- (NSString *)setter;
@end
